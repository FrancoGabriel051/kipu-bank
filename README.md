# KipuBank

## Descripción
Contrato inteligente que permite depositar y retirar ETH de manera segura, con límites por transacción y límite global de depósitos. Registra la cantidad de depósitos y retiros, y emite eventos para cada operación.

## Despliegue
1. Abrir Remix y cargar `KipuBank.sol`.
2. Compilar con Solidity ^0.8.0.
3. Desplegar con los parámetros del constructor (en wei):
   - `_bankCap`: límite global de ETH.
   - `_withdrawLimit`: límite por retiro.

Ejemplo: `10000000000000000000, 1000000000000000000` (10 ETH, 1 ETH).

## Interacción
- `deposit()`: Depositar ETH en tu bóveda.  
- `withdraw(uint256 amount)`: Retirar ETH hasta el límite y según tu balance.  
- `getMyBalance()`, `getMyDepositCount()`, `getMyWithdrawCount()`, `getTotalOperations()`: Consultas de estado.

## Testnet
- Red: Goerli  
- Dirección: `0xTuDireccionDeContrato`  
- Verificación: [Goerli Etherscan](https://goerli.etherscan.io/address/0xTuDireccionDeContrato)