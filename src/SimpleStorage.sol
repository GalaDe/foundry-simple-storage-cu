//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26; //stating the version

contract SimpleStorage {
    uint256 public myFavNum;

    uint256[] arrOfNum;

    function store(uint256 _favNum) public {
        myFavNum = _favNum;
    }

    struct Person {
        uint256 favNum;
        string name;
    }

    Person[] public listOfPpl;

    //Map/Dictionary
    mapping(string => uint256) public nameToFavNum;

    //view - read state from the blockchain and disallow update the state
    //view, puer -- don't spend gas
    function retrieve() public view returns (uint256) {
        return myFavNum;
    }

    function addPerson(string memory _name, uint256 _favNum) public {
        listOfPpl.push(Person(_favNum, _name));
        nameToFavNum[_name] = _favNum;
    }
}
