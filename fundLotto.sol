//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.4.11;
contract FundingLotto {
	
	struct Investor {
		address addr;
		uint amount;	
	}
	
	
	uint randNonce = 0;         // 랜덤숫자
	uint public numInvestors;	// 투자자 수
	uint public deadline;		// 마감일
	string public status;		// 모금활동 스테이터스
	bool public ended;			// 모금 종료여부
	address public owner;		// 컨트랙트 소유자
	uint public goalAmount;		// 목표액
	uint public totalAmount;	// 총 투자액
   
    
	mapping (uint => Investor) public investors;	// 투자자 관리를 위한 매핑
	
	modifier onlyOwner () {
		require(msg.sender == owner);
		_;
	}
	
	/// 생성자
	constructor (uint _duration, uint _goalAmount) {
		owner = msg.sender;

		// 마감일 설정
		deadline = block.timestamp + _duration;

		goalAmount = _goalAmount;
		status = "Funding";
		ended = false;
        randNonce = 0;
		numInvestors = 0;
		totalAmount = 0;
	}
	
	/// 금액 넣기
	function fund() payable public {
		// 모금이 끝났다면 처리 중단
		require(!ended);
		
		Investor storage inv = investors[numInvestors++];
		inv.addr = msg.sender;
		inv.amount = msg.value;
		totalAmount += inv.amount;
	}
	
	/// 목표액 달성 여부 확인

	function checkGoalReached () payable public onlyOwner {		
		// 모금이 끝났다면 처리 중단
		require(!ended);
		
		// 마감이 지나지 않았다면 처리 중단
		require(block.timestamp >= deadline);
		
		if(totalAmount >= goalAmount) {	
			status = "Campaign Succeeded";
			ended = true;
			
			
			//랜덤 함수 생성
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % numInvestors;
			
			// 컨트랙트 소유자에게 컨트랙트에 있는 모든 이더를 송금
			if(!payable(investors[random].addr).send(totalAmount)) {
				revert();
			} 
		} else {	// 모금 실패인 경우
			uint i = 0;
			status = "Campaign Failed";
			ended = true;
			
			// 각 투자자에게 투자금을 돌려줌
			while(i <= numInvestors) {
				if(!payable(investors[i].addr).send(investors[i].amount)) {
					revert();
				}
				i++;
			}
		}
	}
	
	function getBalance() view public returns(uint) {
		return address(this).balance;
	}

	
	/// 컨트랙트를 소멸시키기 위한 함수
	function kill() public onlyOwner {
		selfdestruct(payable(owner));
	}
}
