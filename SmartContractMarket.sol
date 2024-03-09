pragma solidity >=0.4.11;
contract SmartContractMarket {
    address public owner;
    uint public price; // 가격
    uint public numberOfStocks; //재
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    event UpdatePrice(uint _price);
    event Buy(uint _price, uint _quantity, uint _value, uint _change);


    //생성자
    constructor () {
        owner = msg.sender; //컨트랙트 소유 주소
        price = 1000;
        numberOfStocks = 1;
    }
    
    //가격 업데이트
    function updatePrice(uint _price) public onlyOwner {
        price = _price;
        emit UpdatePrice(price);
    }

    function buy(uint _quantity) public payable {
        if (msg.value < _quantity * price || _quantity > numberOfStocks) {
            revert();
        }

        // 거스름돈 송금
        if (!payable(owner).send(msg.value - _quantity * price)) {
            revert();
        }

        numberOfStocks -= _quantity;
        emit Buy(price, _quantity, msg.value, msg.value - _quantity * price);
    
    }



}
