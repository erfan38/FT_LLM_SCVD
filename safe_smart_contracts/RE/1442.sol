contract ElectricQueue  {
       address public Owner;
       uint public syncDate;
       uint public InvestmentsCount;
       uint public ChargersCount;
       Investment[] Investments;
       uint[]  ChargersIds ; 
       mapping (uint=>Charger) Chargers;
       address public Proxy;
       address public Manager;
       //