// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    mapping(address => uint256) public bet_bot;
    mapping(uint => Quiz_item) public quizzes;
    mapping (address => uint256) public playerbal;
    uint public vault_balance;
    address public owner;
    uint256 public quiznum;
    

    constructor () {
        Quiz_item memory q;
        owner = msg.sender;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);
        quizzes[q.id] = q;
        quiznum += 1;
    }

    function getAnswer(uint quizId) public view returns (string memory){
        require(msg.sender == owner);
        return quizzes[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory quiz = quizzes[quizId];
        quiz.answer = "";
        return quiz;
    }

    function getQuizNum() public view returns (uint){
        return quiznum;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory quiz = quizzes[quizId];
        uint256 betval = msg.value;
        uint256 bet_quiz_id = quizId-1;
        address player = msg.sender;
        require(quiz.min_bet <= betval, "more bet");
        require(quiz.max_bet >= betval, "reduce bet");
        bet_bot[player] = betval;
        bets.push();
        bets[bet_quiz_id][player] += betval;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory quiz = quizzes[quizId];
        uint256 bet_quiz_id = quizId-1;
        if(keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(quiz.answer))) {
            playerbal[msg.sender] += bets[bet_quiz_id][msg.sender] * 2;
            return true;
        } else {
            vault_balance += bets[bet_quiz_id][msg.sender];
            bets[bet_quiz_id][msg.sender] = 0;
            return false;
        }
    }

    function claim() public {
        uint256 amount = playerbal[msg.sender];
        playerbal[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    receive() external payable {}

}
