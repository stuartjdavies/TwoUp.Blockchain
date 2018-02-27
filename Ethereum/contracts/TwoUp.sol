pragma solidity ^0.4.0;

contract TwoupFactory {
    address[] public deployedTwoUpGames;

    function createTwoUpGame(uint minimum) public {
        address newTwoup = new Twoup(minimum, msg.sender);
        deployedTwoUpGames.push(newTwoup);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedTwoUpGames;
    }
}

contract Twoup {
    struct Player {
        uint BetAmount;
        address Address;
        bool PickedHeads;
    }
    
    struct TossResult {
        bool HeadsCoinOne;
        bool HeadsCoinTwo;
    }

    TossResult[] public tosses; 
    Player[] public players;
    address public spinner;    
    uint public kitty; 
    uint public totalBet;
    TossResult public gameResult;
    uint256 public totalHeads;
    bool isGameCompleted;
    bool spinnerIsHeads;    
    mapping(address => uint) public playerAmount;

    function Twoup(uint housekitty, address newSpinner) public payable
    {
        require(msg.value > 10 ether);
        spinner = newSpinner;
        kitty = housekitty;
        isGameCompleted = false; 
        totalBet = 0;
    }    

    function enter(bool heads) public payable 
    {
        require(msg.value + totalBet < kitty);
        playerAmount[msg.sender] = msg.value;
        players.push(Player({ Address: msg.sender, BetAmount: msg.value, PickedHeads: heads }));

        if (heads == true) 
            totalHeads = totalHeads + 1; 
    }

    function abandonGame() public
    {
        require(isGameCompleted == false);
        require(msg.sender == spinner);
        spinner.transfer(kitty);                    
    }

    function withdrawFromGame() public 
    {
        require(isGameCompleted == false);
        msg.sender.transfer(playerAmount[msg.sender]);
        // playerAmount[msg.sender].remove();
        delete playerAmount[msg.sender];
        
        for (uint i = 0; i < players.length; i++)
        {
            if (players[i].Address == msg.sender)
            {
                delete players[i];
            }
        }    
    }

    function tossCoin() private view returns (bool) {
        return ((uint(keccak256(block.difficulty, now, players.length)) % 2) == 0);
    }

    function pickWinner() public 
    {
        require(msg.sender == spinner);
        require(isGameCompleted == false);
        spinnerIsHeads = totalHeads > (players.length - totalHeads); 
       
        do 
        {
            tosses.push(TossResult({ HeadsCoinOne: tossCoin(), HeadsCoinTwo: tossCoin() }));
        } while(tosses[tosses.length - 1].HeadsCoinOne != tosses[tosses.length - 1].HeadsCoinTwo);

        bool spinnerWins = (spinnerIsHeads == gameResult.HeadsCoinOne);

        if (spinnerWins)  
        {
            spinner.transfer(this.balance);
        }
        else 
        {
            for(uint256 i = 0; i < players.length; i++)
            {
                players[i].Address.transfer(players[i].BetAmount * 2);
            }   
        } 

        isGameCompleted = true;
    }   

    function getTossesResult(uint index) public view returns(bool, bool)
    {    
        return (tosses[index].HeadsCoinOne, tosses[index].HeadsCoinTwo);
    }

    function getNumberOfTosses() public view returns(uint)
    {
        return tosses.length;
    }

    function getResult() public view returns(bool, bool, bool, bool)
    {
        require(isGameCompleted == true);
        return (isGameCompleted, spinnerIsHeads, gameResult.HeadsCoinOne, gameResult.HeadsCoinTwo);
    }

    function getNumberOfPlayers() public view returns(uint)
    {
        return players.length;
    }

    function getPlayer(uint index) public view returns(uint, address, bool)
    {
        return (players[index].BetAmount, players[index].Address, players[index].PickedHeads);
    }    
}