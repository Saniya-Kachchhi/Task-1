// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    
    return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
    ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    
    return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
    return 0;
    }
    
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    
    return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
    }
    
    function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
    ) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    
    return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
    }
    
    function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
    ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
    }
}

contract Ownable {
    address public admin;

    constructor() {
        admin = msg.sender;    
    } 

     modifier OnlyAdmin() {
        require(admin==msg.sender, "Access Denied!");
        _;
    }
}
contract task is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 _initialSupply;

    constructor( uint256 initialSupply) ERC20("Task", "TSK") {
         _mint(msg.sender, initialSupply);
         _initialSupply = initialSupply;
    } 
    
    struct ProjectOwner{
        address Owner; // Project Owner's address
        string OwnerName;
        string ProjectName;
        bool PaidFees;
        bool PaidBonus;
        uint256 balances;

    }

    struct collaborators{
        address Collaborator; // contributor's address
        string name;
        string ProjectName;
        bool receivedFees;
        bool receivedBonus;
        address ProjectOwner;
        uint256 balances;
    }

    struct Project {
        uint256 Id;
        address Owner; // Project Owner's address.
        uint256 feesAmount;
        uint256 bonusAmount;
    }

    mapping(address => ProjectOwner) public _Owner;
    mapping(address => collaborators) public _collaborator;
    mapping(uint256 => Project) public _Project; 
    mapping(uint256 => mapping(address => bool)) public isCollaborator; 
   

    event Payment(address _ownerId, address _collaboratorId, uint256 Id);
    
    function addOwner(address _ownerId, string memory _ProjectName,string memory _OwnerName) public {
        _Owner[_ownerId].Owner = _ownerId;
        _Owner[_ownerId].ProjectName= _ProjectName;
        _Owner[_ownerId].OwnerName = _OwnerName;
        _Owner[_ownerId].PaidFees = false;
        _Owner[_ownerId].PaidBonus = false;

    }

    function addCollaborator(address _collaboratorId, string memory _ContributorName, string memory _ProjectName) public {
        _collaborator[_collaboratorId].Collaborator = _collaboratorId;
        _collaborator[_collaboratorId].name = _ContributorName;
        _collaborator[_collaboratorId].ProjectName = _ProjectName;
        _collaborator[_collaboratorId].receivedFees = false;
        _collaborator[_collaboratorId].receivedBonus = false;
    }

    function getOwner(address _ownerId) public view returns (string memory, string memory, bool, bool, uint256){
        return (_Owner[_ownerId].OwnerName, _Owner[_ownerId].ProjectName, 
        _Owner[_ownerId].PaidFees, _Owner[_ownerId].PaidBonus, _Owner[_ownerId].balances);
    }

    function getCollaborator(uint256 Id, address _collaboratorId) public view returns (string memory, string memory, bool, bool, address, uint256){
        return (_collaborator[_collaboratorId].name, _collaborator[_collaboratorId].ProjectName, 
        _collaborator[_collaboratorId].receivedFees, _collaborator[_collaboratorId].receivedBonus, _Project[Id].Owner, _collaborator[_collaboratorId].balances);
    }

    function addProject(uint256 Id, uint256 Fees, uint256 Bonus) public {
        //require(!(_Project[Id].Id == 0), "Add valid ID");
        require(_Owner[msg.sender].Owner == msg.sender, "Not the Owner");
        _Project[Id].Owner = msg.sender;
        _Project[Id].Id = Id;
        //require(_Project[Id].Owner == msg.sender);
        require(balanceOf(msg.sender) >= Fees, "Not enough funds");
        _Project[Id].feesAmount = Fees;
        require(balanceOf(msg.sender) >= Bonus, "Not enough funds");
        _Project[Id].bonusAmount = Bonus;

    }
    
    function PayFees(uint256 Id, address[] memory _collaboratorId) public   //uint256 payBonus
      {  
        require(_Project[Id].Owner == msg.sender); //check the ID with addProject
        //ProjectContri[_collaboratorId] = _collaborator[_collaboratorId].Collaborator;
        //collaboratorList[Id][0].push(_collaboratorId);
        uint256 payFees = _Project[Id].feesAmount;
        _initialSupply -= payFees;
        //require(balanceOf(msg.sender) >= payFees, "Not enough funds"); //_collaboratorId.length
        

         _Owner[msg.sender].balances = _initialSupply;
        require(payFees <= _initialSupply, "Not enough Funds!");
        _initialSupply -= payFees;

        
       //transfer(_collaboratorId[i], _Project[Id].feesAmount);
       //transfer(_collaborator[_collaboratorId].Collaborator, _Project[Id].feesAmount);
        
        // address _ownerId;
        // collaboratorList[_ownerI] = _Owner.Owner;
       
        for(uint i=0; i < _collaboratorId.length; i++) {
             
         //collaboratorList[Id].push(_collaboratorId[i]);
            require(_collaborator[_collaboratorId[i]].Collaborator == _collaboratorId[i]);
            //isCollaborator[_Project[Id].Id][_collaboratorId[i]]== true;
             //if(isCollaborator[_Project[Id].Id][_collaboratorId[i]]){
               transfer(_collaboratorId[i], _Project[Id].feesAmount); //_collaboratorId[i]
                 //transfer(, _Project[Id].feesAmount);
                 _collaborator[_collaboratorId[i]].balances += payFees;
             }
      //}
        _Owner[msg.sender].PaidFees = true;
        _collaborator[msg.sender].receivedFees = true;
    }


    function PayBonus(uint256 Id, address[] memory _collaboratorId) public  
      {  
        require(_Project[Id].Owner == msg.sender); //check the ID with addProject
        uint256 payBonus = _Project[Id].bonusAmount;
        require(payBonus <= _initialSupply, "Not enough Funds!");
        _initialSupply -= payBonus;
        
        for(uint i=0; i < _collaboratorId.length; i++) {
             
            require(_collaborator[_collaboratorId[i]].Collaborator == _collaboratorId[i]);
               transfer(_collaboratorId[i], _Project[Id].bonusAmount/_collaboratorId.length);
                 _collaborator[_collaboratorId[i]].balances += payBonus;
             }
        _Owner[msg.sender].PaidBonus = true;
        _collaborator[msg.sender].receivedBonus = true;
    }

}