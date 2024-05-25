// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CypherNFT {
    // owner, name, symbol, balance, approveMinter, totalsupply
    // mint, burn, transfer

    // state variables
    string public name;
    string public symbol;
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public approveMinter;
    mapping(uint256 => address) public _owners;
    mapping(uint256 => string) public tokenURI;
    uint256 public totalsupply;
    
    modifier onlyOwner(){
        if(msg.sender != owner){
            revert("Only owner can call this function");
        }
        _;
    }
    modifier onlyApprovedMinter(){
        if(!approveMinter[msg.sender]){
            revert("Minter not approved");
        }
        _;
    }

    event Mint(address indexed from, address indexed to, uint256 tokenID,string uri);
    event MinterApproved(address indexed minter_, bool approved);
    event Burnt(uint256 tokenID_, address indexed tokenOwner_);
    event Transfer(address indexed from, address indexed to, uint256 tokenID_);

    constructor(string memory name_, string memory symbol_){
        owner = msg.sender;
        name = name_;
        symbol = symbol_;
    }

    function mint(address to, uint256 tokenID, string memory uri ) public onlyApprovedMinter{
        if(existToken(tokenID)){
            revert("Token ID already exist");
        } else if (bytes(uri).length <= 0){
            revert("URI cannot be empty");
        } else if (to == address(0)){
            revert("cannot mint to Zero address");
        }
        tokenURI[tokenID] = uri;
        _owners[tokenID] = to;
        balances[to] += 1;
        totalsupply += 1;
        emit Mint(address(0), to, tokenID,uri);
    }

    function burn(uint256 tokenID_) public {
        address tokenOwner_ = ownerOf(tokenID_);
        if (msg.sender != tokenOwner_) revert("Only tokenOwner can burn token");
        balances[tokenOwner_] -= 1;
        delete _owners[tokenID_];
        totalsupply -= 1;
        
        emit Burnt(tokenID_, tokenOwner_);

    }

    function transfer(address to, uint256 tokenID_) public {
        if (msg.sender == address(0) || to == address(0)){
            revert("Transfer to/from address zero");
        } else if (_owners[tokenID_] != msg.sender){
            revert("Not owner asset ID");
        } else if( to == msg.sender){
            revert("Transfer to self");
        }
        balances[msg.sender] -= 1;
        balances[to] += 1;
        _owners[tokenID_] = to;

        emit Transfer(msg.sender, to, tokenID_);
    }

    function existToken(uint256 tokenID_) public view returns(bool){
        return _owners[tokenID_] != address(0);
    }

    function approveMinter_(address minter_, bool approved) public onlyOwner{
        approveMinter[minter_] = approved;
        emit MinterApproved(minter_, approved);
    }

    function ownerOf(uint256 tokenId_) public view returns(address){
        if (!existToken(tokenId_)) revert("Token does not exists");
        address _tokenOwner = _owners[tokenId_];
        return _tokenOwner;
    }

    function getBalance(address tokenOwner_) public view returns(uint256){
        return balances[tokenOwner_];
    }


} 