// SPDX-License-Identifier: MIT
//-------------------------------------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//-------------------------------------------------------------------------------------------------------------------------------------
// CONTRACT
contract Icarus is ERC20, ERC20Burnable, Ownable {
    uint256 initialSupply;
    uint256 dexSupply;
    uint256 cexSupply;
    uint256 creatorSupply;
    
    address payable public owner;
    address public cexWallet;
    address public creatorWallet;
    
    mapping(address => bool) public blacklists;
    
    bool public limitTrading;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapPool;
        
    uint256 public immutable creationBlock;
    uint256 public immutable blockLimit;
    uint256 public transactionsCounter;
    uint256 public minTransactions;

    //--------------------------------------------------------------
    // CONSTRUCTOR
    constructor() ERC20("Icarus", "ICARUS") {
        initialSupply = 149597870700 * 10 ** decimals();
        dexSupply = initialSupply / 10 * 8;
        cexSupply = initialSupply / 10;
        creatorSupply = initialSupply - dexSupply - cexSupply;
                
        owner = msg.sender;
        cexWallet = <cex_wallet>;
        creatorWallet = <creator_wallet>;
        
        limitTrading = true;
        
        creationBlock = block.number;
        blockLimit = 2555000;
        minTransactions = 1000000;
           
        _mint(owner, dexSupply);
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
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    //--------------------------------------------------------------
    // RENOUNCE CONTRACT OWNERSHIP
    function renounceOwnership() external onlyOwner {
        renounceOwn();
    }

    //--------------------------------------------------------------
    // TRANSACTIONS COUNTER    
    function _afterTokenTransfer(address from, address to, uint256 amount) override internal {
        transactionsCounter = transactionsCounter + 1;
    }
       
    //--------------------------------------------------------------
    // SELF-DESTRUCT
    function selfDestruct() public {
        require(block.number >= creationBlock + blocklimit, "The Doomsday Block hasn't been reached.");
        require(transactionsCounter < maxTransactions, "Hurray, self-destruction has been avoided!");
        selfdestruct(payable(msg.sender));
    } 

}

