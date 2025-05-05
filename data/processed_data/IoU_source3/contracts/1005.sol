contract EmployeeBonusSystem {
 uint256 public companyFoundingDate;
 struct Employee {
 uint256 _baseSalary;
 }
 mapping(address => Employee) public employees;

 function calculateBonus() internal view returns (uint256) {
 uint256 currentDate = block.timestamp;
 uint256 yearsOfService = (currentDate - companyFoundingDate) / (365 days);
 return employees[msg.sender]._baseSalary * yearsOfService / 10;
 }
}