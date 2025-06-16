# KipuBank
Un contrato inteligente de banco simple y seguro que permite a los usuarios depositar y retirar ETH con límites predefinidos.

## 📋 Descripción
KipuBank es un smart contract desarrollado en Solidity que implementa un sistema bancario básico con las siguientes características:

* **Depósitos seguros**: Los usuarios pueden depositar ETH en sus bóvedas personales mediante la función `deposit()` o una transferencia directa que activa la función `receive()`.
* **Retiros limitados**: Los retiros están limitados a un umbral máximo por transacción.
* **Límite global**: El banco tiene un límite máximo de depósitos totales (bank cap).
* **Registro completo**: Lleva estadísticas detalladas de depósitos y retiros.
* **Seguridad**: Implementa patrones de seguridad y errores personalizados.

## 🔧 Características Técnicas
* **Variables Immutable/Constant**
    * `withdrawalLimit`: Límite máximo de retiro por transacción (inmutable).
    * `bankCap`: Límite máximo de depósitos totales (inmutable).
    * `VERSION`: Versión del contrato (constante).
* **Funcionalidades**
    * ✅ Función `external payable` para depósitos.
    * ✅ Función `external` para retiros con validaciones.
    * ✅ Función `external view` para consultas de balance y estadísticas.
    * ✅ Función `private` para transferencias seguras.
    * ✅ Modificador personalizado para validar fondos.
    * ✅ Eventos para depósitos y retiros.
    * ✅ Errores personalizados descriptivos.
* **Mappings**
    * Balance por usuario.
    * Contador de depósitos por usuario.
    * Contador de retiros por usuario.

## 🚀 Instrucciones de Despliegue
### Requisitos Previos
* MetaMask instalado y configurado.
* Acceso a Remix IDE.
* ETH de Sepolia para gas fees.

### Pasos de Despliegue
1.  **Abrir Remix**: Ve a `remix.ethereum.org`.
2.  **Crear un nuevo archivo**: Nómbralo `KipuBank.sol`.
3.  **Copiar el Código**: Copia el código del contrato desde `contracts/KipuBank.sol` y pégalo en Remix.
4.  **Compilar**:
    * Ve a la pestaña "Solidity Compiler".
    * Selecciona una versión del compilador `^0.8.19`.
    * Haz clic en "Compile KipuBank.sol".
5.  **Configurar Red**:
    * Ve a la pestaña "Deploy & Run Transactions".
    * En "Environment", selecciona "Injected Provider - MetaMask".
    * Asegúrate de estar conectado a la Sepolia Testnet.
6.  **Desplegar**:
    * En el constructor, introduce los siguientes parámetros:
        * `_withdrawalLimit`: `100000000000000000` (0.1 ETH en wei)
        * `_bankCap`: `10000000000000000000` (10 ETH en wei)
    * Haz clic en "Deploy" y confirma la transacción en MetaMask.
7.  **Verificar en Etherscan**:
    * Ve a `sepolia.etherscan.io`.
    * Busca la dirección de tu contrato.
    * Ve a la pestaña "Contract" y haz clic en "Verify and Publish".

## 📖 Cómo Interactuar con el Contrato
### Realizar un Depósito
* **Método 1: Función `deposit()`**
    1.  En Remix, bajo "Deployed Contracts", busca tu contrato.
    2.  Introduce el valor a depositar en el campo "VALUE" (ej: `0.05` ETH).
    3.  Haz clic en el botón `deposit` y confirma la transacción.
* **Método 2: Transferencia directa**
    * Envía ETH directamente a la dirección del contrato. Se ejecutará automáticamente la función `receive()`.

### Realizar un Retiro
1.  Introduce la cantidad a retirar en wei en el campo `amount` de la función `withdraw`.
    * *Ejemplo*: `50000000000000000` (para 0.05 ETH).
2.  Haz clic en `withdraw` y confirma la transacción.

### Consultar Información
* **`getUserBalance`**: Introduce la dirección de un usuario para ver su balance.
* **`getUserStats`**: Introduce la dirección de un usuario para ver su balance, número de depósitos y retiros.
* **`getBankStats`**: Haz clic en el botón para ver las estadísticas globales del banco.

## 🔒 Características de Seguridad
* **Checks-Effects-Interactions**: Patrón implementado en todas las funciones de cambio de estado para prevenir ataques de reentrada.
* **Errores personalizados**: Mensajes claros y eficientes en gas para cada condición de fallo.
* **Modificadores**: Validación de condiciones (como `hasDeposits`) antes de ejecutar la lógica de la función.
* **Transferencias seguras**: Uso de `call{value: ...}("")` con verificación de éxito para enviar ETH.
* **Límites de retiro y depósito**: Protección contra retiros excesivos y control del capital total del banco.

## 📊 Eventos
El contrato emite los siguientes eventos para el seguimiento off-chain:
* `DepositMade(address indexed user, uint256 amount, uint256 newBalance)`
* `WithdrawalMade(address indexed user, uint256 amount, uint256 newBalance)`

## 🧪 Testnet Deployment
* **Red**: Sepolia Testnet
* **Dirección del Contrato**: `0x8ca31c60dd980ffe94e67053d0d1c5a56a428d80`
* **Explorador**: [Ver en Sepolia Etherscan](https://sepolia.etherscan.io/address/0x8ca31c60dd980ffe94e67053d0d1c5a56a428d80)
* **Transacción de Ejemplo (Depósito)**: [Ver Transacción en Etherscan](https://sepolia.etherscan.io/tx/0x944cd02c4d94fdd5594f0ea3cead311ad64a0c4f01b832dee760dfdffca2da4e)

## 🛠️ Desarrollo
### Tecnologías Utilizadas
* Solidity `^0.8.19`
* Inspirado en patrones de seguridad de OpenZeppelin
* Remix IDE
* MetaMask
* Sepolia Testnet

### Estructura del Proyecto

kipu-bank/
├── contracts/
│   └── KipuBank.sol
└── README.md

## 📝 Licencia
Este proyecto está bajo la Licencia MIT.

## 👨‍💻 Autor
* **alejoherrera**
* **GitHub**: [@alejoherrera](https://github.com/alejoherrera)
* **Sitio Web**: [alejoherrera.com](https://alejoherrera.com)

*Desarrollado para examen del Módulo 2 de ETH Kipu. Gracias*