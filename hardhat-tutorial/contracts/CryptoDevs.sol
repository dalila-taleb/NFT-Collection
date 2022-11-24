//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/** Warning : If solidity extention is upper to 0.135, the next lines will bi highlited and imported contracts willl not be found*/
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";
import "hardhat/console.sol";


contract CryptoDevs is ERC721Enumerable, Ownable {
    /**
      * @dev _baseTokenURI for computing {tokenURI}.
      * If set, the resulting URI for each token will be the 
      * concatenation of the baseURIL and the tokenId.
     */

    string _baseTokenURI;

    // _price is the price of one Crypto Dev NFT
    uint256 public _price = 0.01 ether;

    //_paused is used to pause the contract if any emergency
    bool public _paused;

    // max number of CryptoDevs
    uint256 public maxTokenIds =20;

    // total number of tokenIds minted
    uint256 public tokenIds;

    // Whitelist conntract instance
    IWhitelist whitelist;

    // boolean to keep track of whether presale started or not
    bool public presaleStarted;

    // timestamp for when the presale would end
    uint256 public presaleEnded;

    // This function modifier will be used to change the behavour of 
    // another function
    // If the condition is satisfied, the _ will be replaced by the body of 
    // the other function
    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    /** Constructor of the contract takes two params : baseURI & whitelistContract
      * ERC721 constructor take two params : 
      * name : 'Crypto Devs'
      * symbol : 'CD'
    */
    constructor (string memory baseURI, address whitelistContract) ERC721("Crypro Devs", "CD") {
        _baseTokenURI = baseURI; // sets _baseTokenURI for the collection
        whitelist = IWhitelist(whitelistContract); // initializes an instance of whitelist interface
    }

    // This function starts the presale for the whitelisted adresses
    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
        console.log ("presale will inded in %s",presaleEnded);
    }

    /** 
      * Allows a whitelisted user to mint one NFT per transaction during the presale.
      */
    function presaleMint() public payable onlyWhenNotPaused{
        // Some conditions must be satisfied
        // 1 - Check the time, must be within the presale period
        require(presaleStarted &&  block.timestamp < presaleEnded ,"Presale is not runing!" );
        // 2 - The user address is in the whitelisted adress
        require(whitelist.whitelistedAddresses(msg.sender),"You are not in the whitelist !" );
        // 3- Should not exceed the maximum cryptodevs
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply !" );
        // 4- The value of eth sent must be equal or higher that the price of the crypto devs 
        require(msg.value >= _price ,"Ether sent is not correct" );

        // safeMint is a safer version of the _mint function. It ensures that :
        // 
        tokenIds +=1;
        _safeMint(msg.sender, tokenIds);        
    }

    /** 
      * Allows a user to mint one NFT per transaction after the presale.
      */
    function mint() public payable onlyWhenNotPaused{
        // Some conditions must be satisfied
        // 1 - Check the time, must be upper to presale period
        require(presaleStarted &&  block.timestamp >= presaleEnded ,"Presale has not ended yet!" );
        // 2- Should not exceed the maximum cryptodevs
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply !" );
        // 3- The value of eth sent must be equal or higher that the price of the crypto devs 
        require(msg.value >= _price ,"Ether sent is not correct" );

        // safeMint is a safer version of the _mint function. It ensures that :
        // 
        tokenIds +=1;
        _safeMint(msg.sender, tokenIds);        
    }

    /**
      * @dev _baseURIL overides the openzeppelin's ERC721 implementation which returns
      * an empty string for the baseURI
       */
    function _baseURI() internal view virtual override returns (string memory){
        return _baseTokenURI;
    }

    /**
      * setpaused makes the contract paused or unpaused */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
      * withdraw sends all the ether in the contract 
      * to the owner of the contract
     */
    function withdraw() public onlyOwner {

        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value:amount}("");
        require(sent, "Failed to send Ether! ");
    }

    // function to receive Ether, msg.data must be empty
    receive() external payable{}

    // fallback is called when msg.data is not empty
    fallback() external payable {}
}
