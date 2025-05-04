// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; //shows the version of solidity in use
 /*This contract will allow a user to register a candidate.
the user can vote and view results
*/
contract Ownable {
    address public owner;
    constructor() { //sets the owner of the contract
        owner = msg.sender;
    }
    
    //modifier to restrict access of functions to the owner
    modifier onlyOwner(){
        require(msg.sender==owner, "Only the owner can perform this function.");
        _;
    }
}
//contract to implement voting system
//the below contract inherits from contract ownable
contract VotingSystem is Ownable{
    //struct is a user-defined data type that allows you to group related variables under a single name
    //struct to represent candidate
    struct Candidate{
     uint id;
     string name;
     uint voteCount;

    }
    uint public candidateCount=0;
    
    //mappings to store registered candidates by ID
    mapping(uint =>Candidate ) public candidates;
    //checks by address who has voted 
    mapping(address => bool) public hasvoted;

    //function to add new candidates to list 
    function addCandidate(string calldata name) external onlyOwner{
        //iteration to add newly registered candidates
        candidateCount++;
        candidates[candidateCount] = Candidate({
         id: candidateCount,
         name: name,
         voteCount: 0
        });
    }

    // function to allow an address to vote for a candidate only once
    function vote( uint candidateId) public {
        require(!hasvoted[msg.sender], "You have already voted.");
        require(candidateId >0 && candidateId <= candidateCount, "Invalid candidat ID.");

        hasvoted[msg.sender] = true;

        //storage to update candidate
        Candidate storage selectedCandidate = candidates[candidateId];
        selectedCandidate.voteCount++;

    }
    // function to return candidate's details
   function getCandidate(uint candidateId) public view returns (string memory name, uint voteCount){
    require(candidateId >0 && candidateId <= candidateCount, "Candidate does not exist.");
    Candidate storage c = candidates[candidateId];
    return (c.name, c.voteCount);
   }

  //this function fetch/list all candidates
  function getTotalCandidates() public view returns (uint){
     return candidateCount;
   }

}


