// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EventParticipation is ERC721URIStorage {


    address owner; // Access controls so not everyone can randomly issue participation attestation. Only this owner can. 
    using Counters for Counters.Counter;
    Counters.Counter private _tokendIDs; // tokendIDs var for tokenURI of type Counters.Counter

    constructor() ERC721("EventParticipation", "Participation") { // First arg: NFT Collection Name, Second arg: NFT Collection Symbol
        owner = msg.sender; // you set in the constructor that the owner is the person who deployed the contract. which is msg.sender
    }

    mapping(address => bool) public issuedParticipations; // recording which addresses have a degree issued. once it is set to true to an address, that address can come and claim that attestation.  and we will create a seperate function for that. 

    modifier onlyOwner() { // specify a modifier. piece of code you called before the following function code gets executed and you tie them to a function, so just defining onlyOwner
        require(msg.sender == owner);  // person who is executing this function, i.e. the owner. And how do you know this person is the owner? You set it in the constructor 
        _; // _ represents all the code in this function 
    }

    function issueParticipation(address to) onlyOwner external {
        issuedParticipations[to] = true; // to access issuedParticipations mappings. This is how we issue degrees. Should be only called by the owner, 
    }

    function claimParticipation(string memory tokenURI) public returns (uint256) { // called by all the participants. string will be stored in memory and we will call this token URI. It will be public so anyone can call it. And it returns uint256 which is the token ID and that is what we use the counters for. 
        require(issuedParticipations[msg.sender], "Participation is not issued"); // person who wants to claim actually has the permission. To check this we will check the mappings with the address of msg.sender, this is the person that calls the contract. If there is an error, we just throw an error saying degree is not issued. 

        _tokendIDs.increment(); // every time a new token ID is issued, you want to increment it 
        uint256 newItemId = _tokendIDs.current(); // incremented tokendID
        _mint(msg.sender, newItemId); // call the mint function with the person that called the contract. And with this newItemId which we have incremented with the tokendID which is the current tokendID
        _setTokenURI(newItemId, tokenURI);

        personToParticipation[msg.sender] = tokenURI; // set the tokeURI to the person
        issuedParticipations[msg.sender] = false; // set it to false so the person that already minted this NFT cannot mint it twice

        return newItemId;

    }

    mapping(address => string) public personToParticipation; // this will useful for a third party who has the address of this person and wants to see the attestation. this will be an address mapped to the string. the string will be a link which will be public. 

}

        
