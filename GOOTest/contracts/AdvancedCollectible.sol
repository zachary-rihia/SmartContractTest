// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {

    enum Breed{PUG, SHIBA_INU, ST_BERNARD}

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public tokenCounter;

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    mapping(uint256 => Breed) public tokenIdToBreed;
    event requestedCollectible(bytes32 indexed requestId);

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash) public
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    // name and symbol
    ERC721("Testing", "TEST")
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    // creates collectible 
     function createCollectible(uint256 userProvidedSeed, string memory tokenURI)
     public returns (bytes32) 
     {
        bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed); // keyhash is used to see if it is truly random
        requestIdToSender[requestId] = msg.sender; // makes sure it goes to the correct user
        requestIdToTokenURI[requestId] = tokenURI; // this would be how you set the tokenURI if you want to set the tokenURI
        emit requestedCollectible(requestId); // for testing to make sure that the requestId is happening and is the correct one
     }

    // to make sure it is random to make sure the nfts arent repeating 
     function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override 
     {
        address dogOwner = requestIdToSender[requestId]; // unpacking from mapping
        string memory tokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter; // new id
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3); // can be used random stats or for this case a random breed which is stored in the enum
        tokenIdToBreed[newItemId] = breed; // asigns the above stat to the tokenID
        requestIdToTokenId[requestId] = newItemId; // testing to make sure the tokenID and the iremId are the same
        tokenCounter = tokenCounter + 1;
     }

    // sets the correct tokenID to the correct tokenURI
     function setTokenURI(uint256 tokenId, string memory _tokenURI) public 
     {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _setTokenURI(tokenId, _tokenURI);
    }
}