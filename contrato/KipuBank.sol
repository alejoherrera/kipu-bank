// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title KipuBank
 * @author Tu Nombre
 * @notice Un contrato de banco simple que permite depósitos y retiros de ETH
 * @dev Implementa límites de depósito global y retiro por transacción
 */
contract KipuBank {
    
    // ========== VARIABLES IMMUTABLE Y CONSTANT ==========
    
    /**
     * @notice Límite máximo de retiro por transacción (0.1 ETH)
     * @dev Variable immutable establecida en el constructor
     */
    uint256 public immutable withdrawalLimit;
    
    /**
     * @notice Límite máximo de depósitos totales en el banco (10 ETH)
     * @dev Variable immutable establecida en el constructor
     */
    uint256 public immutable bankCap;
    
    /**
     * @notice Versión del contrato
     * @dev Variable constante para identificar la versión
     */
    string public constant VERSION = "1.0.0";
    
    // ========== VARIABLES DE STORAGE ==========
    
    /**
     * @notice Total de ETH depositado en el banco
     * @dev Se actualiza en cada depósito y retiro
     */
    uint256 public totalDeposited;
    
    /**
     * @notice Contador total de depósitos realizados
     * @dev Se incrementa en cada depósito exitoso
     */
    uint256 public totalDeposits;
    
    /**
     * @notice Contador total de retiros realizados
     * @dev Se incrementa en cada retiro exitoso
     */
    uint256 public totalWithdrawals;
    
    /**
     * @notice Dirección del propietario del contrato
     * @dev Se establece en el constructor con msg.sender
     */
    address public owner;
    
    // ========== MAPPING ==========
    
    /**
     * @notice Mapeo de direcciones a sus balances depositados
     * @dev Lleva registro del balance de cada usuario
     */
    mapping(address => uint256) public userBalances;
    
    /**
     * @notice Mapeo de direcciones a número de depósitos realizados
     * @dev Lleva registro de cuántos depósitos ha hecho cada usuario
     */
    mapping(address => uint256) public userDepositCount;
    
    /**
     * @notice Mapeo de direcciones a número de retiros realizados
     * @dev Lleva registro de cuántos retiros ha hecho cada usuario
     */
    mapping(address => uint256) public userWithdrawalCount;
    
    // ========== EVENTOS ==========
    
    /**
     * @notice Evento emitido cuando un usuario realiza un depósito exitoso
     * @param user Dirección del usuario que depositó
     * @param amount Cantidad depositada en wei
     * @param newBalance Nuevo balance del usuario después del depósito
     */
    event DepositMade(address indexed user, uint256 amount, uint256 newBalance);
    
    /**
     * @notice Evento emitido cuando un usuario realiza un retiro exitoso
     * @param user Dirección del usuario que retiró
     * @param amount Cantidad retirada en wei
     * @param newBalance Nuevo balance del usuario después del retiro
     */
    event WithdrawalMade(address indexed user, uint256 amount, uint256 newBalance);
    
    // ========== ERRORES PERSONALIZADOS ==========
    
    /**
     * @notice Error cuando el depósito excede el límite del banco
     * @param attempted Cantidad que se intentó depositar
     * @param limit Límite máximo permitido
     */
    error DepositExceedsBankCap(uint256 attempted, uint256 limit);
    
    /**
     * @notice Error cuando el depósito es de 0 ETH
     */
    error DepositMustBeGreaterThanZero();
    
    /**
     * @notice Error cuando el retiro excede el límite por transacción
     * @param attempted Cantidad que se intentó retirar
     * @param limit Límite máximo por transacción
     */
    error WithdrawalExceedsLimit(uint256 attempted, uint256 limit);
    
    /**
     * @notice Error cuando el retiro excede el balance del usuario
     * @param attempted Cantidad que se intentó retirar
     * @param available Balance disponible del usuario
     */
    error InsufficientBalance(uint256 attempted, uint256 available);
    
    /**
     * @notice Error cuando el retiro es de 0 ETH
     */
    error WithdrawalMustBeGreaterThanZero();
    
    /**
     * @notice Error cuando la transferencia de ETH falla
     */
    error TransferFailed();
    
    /**
     * @notice Error cuando el usuario no tiene fondos depositados
     */
    error NoFundsDeposited();
    
    // ========== MODIFICADORES ==========
    
    /**
     * @notice Modificador que verifica que el usuario tenga fondos depositados
     * @dev Revierte si el balance del usuario es 0
     */
    modifier hasDeposits() {
        if (userBalances[msg.sender] == 0) {
            revert NoFundsDeposited();
        }
        _;
    }
    
    // ========== CONSTRUCTOR ==========
    
    /**
     * @notice Constructor del contrato KipuBank
     * @dev Establece los límites immutable y el propietario
     * @param _withdrawalLimit Límite máximo de retiro por transacción
     * @param _bankCap Límite máximo de depósitos totales en el banco
     */
    constructor(uint256 _withdrawalLimit, uint256 _bankCap) {
        withdrawalLimit = _withdrawalLimit;
        bankCap = _bankCap;
        owner = msg.sender;
    }
    
    // ========== FUNCIONES EXTERNAL PAYABLE ==========
    
    /**
     * @notice Permite a los usuarios depositar ETH en su bóveda personal
     * @dev Función payable que acepta ETH y actualiza el balance del usuario
     * Requirements:
     * - El depósito debe ser mayor que 0
     * - El depósito no debe exceder el límite del banco
     */
    function deposit() external payable {
        // Checks
        if (msg.value == 0) {
            revert DepositMustBeGreaterThanZero();
        }
        
        if (totalDeposited + msg.value > bankCap) {
            revert DepositExceedsBankCap(msg.value, bankCap - totalDeposited);
        }
        
        // Effects
        userBalances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        totalDeposits++;
        userDepositCount[msg.sender]++;
        
        // Interactions (emit event)
        emit DepositMade(msg.sender, msg.value, userBalances[msg.sender]);
    }
    
    /**
     * @notice Permite a los usuarios retirar ETH de su bóveda personal
     * @dev Función external que transfiere ETH al usuario
     * @param amount Cantidad a retirar en wei
     * Requirements:
     * - El usuario debe tener fondos depositados
     * - La cantidad debe ser mayor que 0
     * - La cantidad no debe exceder el límite de retiro por transacción
     * - El usuario debe tener suficiente balance
     */
    function withdraw(uint256 amount) external hasDeposits {
        // Checks
        if (amount == 0) {
            revert WithdrawalMustBeGreaterThanZero();
        }
        
        if (amount > withdrawalLimit) {
            revert WithdrawalExceedsLimit(amount, withdrawalLimit);
        }
        
        if (amount > userBalances[msg.sender]) {
            revert InsufficientBalance(amount, userBalances[msg.sender]);
        }
        
        // Effects
        userBalances[msg.sender] -= amount;
        totalDeposited -= amount;
        totalWithdrawals++;
        userWithdrawalCount[msg.sender]++;
        
        // Interactions
        _safeTransfer(msg.sender, amount);
        
        emit WithdrawalMade(msg.sender, amount, userBalances[msg.sender]);
    }
    
    // ========== FUNCIONES EXTERNAL VIEW ==========
    
    /**
     * @notice Obtiene el balance de un usuario específico
     * @dev Función view que no modifica el estado
     * @param user Dirección del usuario a consultar
     * @return balance Balance del usuario en wei
     */
    function getUserBalance(address user) external view returns (uint256 balance) {
        return userBalances[user];
    }
    
    /**
     * @notice Obtiene estadísticas completas del banco
     * @dev Función view que retorna múltiples valores
     * @return _totalDeposited Total depositado en el banco
     * @return _totalDeposits Número total de depósitos
     * @return _totalWithdrawals Número total de retiros
     * @return _bankUtilization Porcentaje de utilización del banco (en basis points)
     */
    function getBankStats() external view returns (
        uint256 _totalDeposited,
        uint256 _totalDeposits,
        uint256 _totalWithdrawals,
        uint256 _bankUtilization
    ) {
        _totalDeposited = totalDeposited;
        _totalDeposits = totalDeposits;
        _totalWithdrawals = totalWithdrawals;
        
        // Calcular utilización como porcentaje * 100 (basis points)
        if (bankCap > 0) {
            _bankUtilization = (totalDeposited * 10000) / bankCap;
        } else {
            _bankUtilization = 0;
        }
    }
    
    /**
     * @notice Obtiene estadísticas de un usuario específico
     * @dev Función view que retorna información detallada del usuario
     * @param user Dirección del usuario a consultar
     * @return balance Balance actual del usuario
     * @return deposits Número de depósitos realizados
     * @return withdrawals Número de retiros realizados
     */
    function getUserStats(address user) external view returns (
        uint256 balance,
        uint256 deposits,
        uint256 withdrawals
    ) {
        balance = userBalances[user];
        deposits = userDepositCount[user];
        withdrawals = userWithdrawalCount[user];
    }
    
    // ========== FUNCIONES PRIVATE ==========
    
    /**
     * @notice Transfiere ETH de forma segura a una dirección
     * @dev Función private que maneja la transferencia de ETH con verificación de éxito
     * @param to Dirección de destino
     * @param amount Cantidad a transferir en wei
     */
    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }
    
    // ========== FUNCIÓN DE RESPALDO ==========
    
    /**
     * @notice Función receive para manejar transferencias directas de ETH
     * @dev Redirige a la función deposit()
     */
    receive() external payable {
        // Checks
        if (msg.value == 0) {
            revert DepositMustBeGreaterThanZero();
        }
        
        if (totalDeposited + msg.value > bankCap) {
            revert DepositExceedsBankCap(msg.value, bankCap - totalDeposited);
        }
        
        // Effects
        userBalances[msg.sender] += msg.value;
        totalDeposited += msg.value;
        totalDeposits++;
        userDepositCount[msg.sender]++;
        
        // Interactions
        emit DepositMade(msg.sender, msg.value, userBalances[msg.sender]);
    }
}

