// SPDX-License-Identifier: MIT
pragma solidity > 0.8.0;

/// @title KipuBank - Vault seguro para depósitos y retiros de ETH
/// @notice Los usuarios pueden depositar y retirar ETH hasta un límite por transacción, con control de depósitos globales.
/// @dev Implementa patrones de seguridad, errores custom, eventos y contadores de depósitos/retiros.
contract KipuBank {

    // ========================
    // ===== Variables de Estado
    // ========================
    mapping(address => uint256) private vault;           // boveda personal de cada usuario
    mapping(address => uint256) private userDeposits;    // numero de depositos por usuario
    mapping(address => uint256) private userWithdraws;   // numero de retiros por usuario

    uint256 public totalDeposited;                       // total depositado actualmente en el contrato
    uint256 public immutable bankCap;                    // limite de depositos permitido
    uint256 public immutable withdrawLimit;              // limite de retiro por transaccion

    uint256 public totalOperations;                     // contador global de depósitos y retiros
    
    // ========================
    // ===== Eventos
    // ========================

    event Deposited(address indexed who, uint256 amount, uint256 userBalance, uint256 userDepositCount);
    event Withdrawn(address indexed who, uint256 amount, uint256 userBalance, uint256 userWithdrawCount);

    // ========================
    // ===== Errores personalizados
    // ========================
    error InvalidAmount();
    error ExceedsBankCap(uint256 attempted, uint256 cap);
    error ExceedsWithdrawLimit(uint256 requested, uint256 limit);
    error InsufficientBalance(uint256 requested, uint256 available);
    error TransferFailed();

    bool flag;
    modifier reentrancyGuard() {
        if (flag) revert();
        flag = true;
        _;
        flag = false;
    }

    // ========================
    // ===== Constructor
    // ========================

    constructor(uint256 _bankCap, uint256 _withdrawLimit) {
        if (_bankCap == 0 || _withdrawLimit == 0) revert InvalidAmount();
        bankCap = _bankCap;
        withdrawLimit = _withdrawLimit;
    }

    // ========================
    // ===== Funciones Externas
    // ========================

    /// @notice Deposito en la cuenta personal del usuario
    function deposit() external payable {
        if (msg.value == 0) revert InvalidAmount();

        unchecked {
            uint256 newTotal = totalDeposited + msg.value;
            if (newTotal > bankCap) revert ExceedsBankCap(newTotal, bankCap);

            vault[msg.sender] += msg.value;
            totalDeposited = newTotal;

            userDeposits[msg.sender]++;
            totalOperations++;
        }
        
        emit Deposited(msg.sender, msg.value, vault[msg.sender], userDeposits[msg.sender]);
    }

    /// @notice Retiro de la cuenta del usuario hasta el limite por transaccion
    function withdraw(uint256 amount) external reentrancyGuard {
        if (amount == 0) revert InvalidAmount();

        if (amount > withdrawLimit) revert ExceedsWithdrawLimit(amount, withdrawLimit);

        uint256 userBal = vault[msg.sender];
        if (amount > userBal) revert InsufficientBalance(amount, userBal);

        vault[msg.sender] = userBal - amount;
        totalDeposited -= amount;
        
        userWithdraws[msg.sender] += 1;
        totalOperations++;

        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Withdrawn(msg.sender, amount, vault[msg.sender], userWithdraws[msg.sender]);
    }

    // ========================
    // ===== Funciones Privadas
    // ========================

    function _sendEth(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    // ========================
    // ===== Funciones de Vista
    // ========================

    function getMyBalance() external view returns (uint256) {
        return vault[msg.sender];
    }
     function getMyDepositCount() external view returns (uint256) {
        return userDeposits[msg.sender];
    }
    function getMyWithdrawCount() external view returns (uint256) {
        return userWithdraws[msg.sender];
    }
    function getTotalOperations() external view returns (uint256) {
        return totalOperations;
    }
}