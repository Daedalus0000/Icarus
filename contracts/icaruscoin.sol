// SPDX-License-Identifier: MIT
//-------------------------------------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//-------------------------------------------------------------------------------------------------------------------------------------
// CONTRACT
contract Icarus is ERC20, ERC20Burnable, Ownable {
    uint256 public immutable initialSupply;
    uint256 public immutable dexSupply;
    uint256 public immutable cexSupply;
    uint256 public immutable creatorSupply;
    
    address public immutable dexWallet;
    address public immutable cexWallet;
    address public immutable creatorWallet;
    
    mapping(address => bool) public blacklists;
    
    bool public limitTrading;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapPool;
        
    uint256 public immutable creationBlock;
    uint256 public immutable blockLimit;
    uint256 public immutable minTransactions;
    uint256 public transactionCounter;

    //--------------------------------------------------------------
    // CONSTRUCTOR
    constructor() ERC20("Icarus", "ICARUS") {
        initialSupply = 149597870700 * 10 ** decimals();
        dexSupply = initialSupply / 10 * 8;
        cexSupply = initialSupply / 10;
        creatorSupply = initialSupply - dexSupply - cexSupply;
                
        dexWallet = msg.sender;
        cexWallet = 0x042DAe440FD05cd84d84EB1a2F6e3811a9D57800;
        creatorWallet = 0x9622e79e6a0D138d60a36aa5cB7c063462277fe5;
        
        limitTrading = true;
        
        creationBlock = block.number;
        blockLimit = 2555000;
        minTransactions = 1000000;
        transactionCounter = 0;
           
        _mint(msg.sender, dexSupply);
        _mint(cexWallet, cexSupply);
        _mint(creatorWallet, creatorSupply);
    }
    
    //--------------------------------------------------------------
    // BLACKLIST
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }   
    
    //--------------------------------------------------------------
    // SET TRADING RULES
    function setRule(bool _limitTrading, address _uniswapPool, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limitTrading = _limitTrading;
        uniswapPool = _uniswapPool;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }
    
    //--------------------------------------------------------------
    // INITIALIZE LIQUIDITY POOL
    function _beforeTokenTransfer(address from, address to, uint256 amount) override internal {
        require(!blacklists[to] && !blacklists[from], "Address Blacklisted");

        if (uniswapPool == address(0)) {
            require(from == dexWallet || to == dexWallet, "Token transfer not available");
            return;
        }

        if (limitTrading && from == uniswapPool) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Trading limited");
        }
    }
    
    //--------------------------------------------------------------    
    // BURN TOKEN
    function burnToken(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    //--------------------------------------------------------------
    // RENOUNCE CONTRACT OWNERSHIP
    function renounceContract() external onlyOwner {
        renounceOwnership();
    }

    //--------------------------------------------------------------
    // TRANSACTION COUNTER    
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        transactionCounter += 1;
        super._afterTokenTransfer(from, to, amount);
    }
    
    //--------------------------------------------------------------
    // GET TRANSACTION COUNT    
    function getTransactionsCount() external view returns (uint256) {
        return transactionCounter;
    }     
       
    //--------------------------------------------------------------
    // SELF-DESTRUCT
    function destroyContract() external {
        require(block.number >= creationBlock + blockLimit, "The Doomsday Block hasn't been reached.");
        require(transactionCounter < minTransactions, "Hurray, self-destruction has been avoided!");
        selfdestruct(payable(msg.sender));
    } 

}

