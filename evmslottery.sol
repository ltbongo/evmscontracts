// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract evmslottery is ReentrancyGuard, Ownable, VRFConsumerBaseV2 {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 private s_subscriptionId;
    bytes32 private keyHash;
    uint16 private requestConfirmations = 3;
    uint32 private numWords =  6;
    uint32 private callbackGasLimit = 2500000;
    address public s_owner;
    address public ownersFeeWallet;
    address private factoryWallet;
    address public factoryContract;
    uint256 public winningDebt = 0;
    uint256 public winningsPaid = 0;
    bool public initialized;
    bool public contractLive;
    string public websiteAddress;
    uint256 public fee = 0.0025 ether;

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;
    uint256 public lastRequestId;

    IERC20 public paytoken;
    uint256 public currentLotteryId;
    uint256 public currentTicketId;
    uint256 public ticketPrice;
    uint[6] public manualnumbers; // for testing winner allocations ( to be removed in production )
    uint256 public cat1Winners;
    uint256 public cat2Winners;
    uint256 public cat3Winners;
    uint256 public cat4Winners;
    uint256 public cat5Winners;

    enum Status {
        Close,
        Open,
        Claimable
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256 endTime;
        uint256 firstTicketId;
        uint256 transferJackpot;
        uint256 category1Jackpot;
        uint256 category2Jackpot;
        uint256 category3Jackpot;
        uint256 category4Jackpot;
        uint256 category5Jackpot;
        uint256 lastTicketId;
        uint[6] winningNumbers;
        uint256 c1Winners;
        uint256 c2Winners;
        uint256 c3Winners;
        uint256 c4Winners;
        uint256 c5Winners;
    }

    enum TicketStatus {
        NoWinner, 
        Category1, 
        Category2, 
        Category3, 
        Category4, 
        Category5,
        Claimed
    }

    struct Ticket {
        uint256 ticketId;
        address owner;
        uint[6] chooseNumbers;
        TicketStatus status;
        uint256 winAmount;
    }

    uint256 private constant CATEGORY_1_PCT = 5;
    uint256 private constant CATEGORY_2_PCT = 10;
    uint256 private constant CATEGORY_3_PCT = 15;
    uint256 private constant CATEGORY_4_PCT = 20;
    uint256 private constant CATEGORY_5_PCT = 50;

    mapping(uint256 => Lottery) private _lotteries;
    mapping(uint256 => Ticket) private _tickets;
    mapping(uint256 => mapping(uint32 => uint256)) private _numberTicketsPerLotteryId;
    mapping(address => mapping(uint256 => uint256[])) private _userTicketIdsPerLotteryId;
    mapping(address => mapping(uint256 => uint256)) public _winnersPerLotteryId;
    mapping(address => uint256[]) private _userTicketIdsPerAddress;

    event LotteryWinnerNumber(uint256 indexed lotteryId, uint[6] finalNumber);

    event LotteryClose(
        uint256 indexed lotteryId,
        uint256 lastTicketId
    );

    event LotteryOpen(
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 endTime,
        uint256 ticketPrice,
        uint256 firstTicketId,
        uint256 transferJackpot,
        uint256 category1Jackpot,
        uint256 category2Jackpot,
        uint256 category3Jackpot,
        uint256 category4Jackpot,
        uint256 category5Jackpot,
        uint256 lastTicketId
    );

    event TicketsPurchase(
        address indexed buyer,
        uint256 indexed lotteryId,
        uint[6] chooseNumbers
    );

    event TicketClaimed(
        uint256 indexed ticketId, 
        address indexed owner, 
        uint256 winningAmount
    );

    event ContractInitialized(
        IERC20 indexed paytoken,
        uint256 ticketPrice,
        bytes32 keyHash,
        address indexed ownersFeeWallet,
        address indexed factoryWallet
    );

    event NumbersDrawn(
        uint256[] numArray, 
        uint[6] finalNumbers
    );

    event WinnersCounted(
        uint256 cat1Winners,
        uint256 cat2Winners,
        uint256 cat3Winners,
        uint256 cat4Winners,
        uint256 cat5Winners,
        uint256 cat1prize,
        uint256 cat2prize,
        uint256 cat3prize,
        uint256 cat4prize,
        uint256 cat5prize
    );

    constructor(address vrfCoordinator) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        initialized = false;
    }
/**
##############################################################################################
 */
    function initialize(
        uint64 _subscriptionId,
        IERC20 _paytoken,
        uint256 _ticketPrice,
        bytes32 _keyHash,
        address _ownersFeeWallet,
        address _factoryWallet,
        address _factoryContract
        ) public {
        require(!initialized, "Contract already initialized");
        s_subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        paytoken = _paytoken;
        ownersFeeWallet = _ownersFeeWallet;
        factoryWallet = _factoryWallet;
        factoryContract = _factoryContract;
        ticketPrice = _ticketPrice;
        initialized = true; 

        emit ContractInitialized(
            _paytoken,
            _ticketPrice,
            _keyHash,
            _ownersFeeWallet,
            _factoryWallet
        );       
    }

    function startLottery(uint256 amount) external onlyOwner {
        require(!contractLive, "Contract already Started");
        paytoken.safeTransferFrom(address(msg.sender), address(this), amount);
        openLottery();
    }

    function openLottery() public nonReentrant {
        require(msg.sender == owner() || msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
        require(_lotteries[currentLotteryId].status != Status.Open, "Lottery not ready");
        currentLotteryId++;
        currentTicketId++;
        uint256 paytokenBalance = paytoken.balanceOf(address(this));
        uint256 fundJackpot = (_lotteries[currentLotteryId].transferJackpot).add(((paytokenBalance.mul(80)).div(100)).sub(winningDebt));
        uint256 transferJackpot;
        uint256 category1Jackpot;
        uint256 category2Jackpot;
        uint256 category3Jackpot;
        uint256 category4Jackpot;
        uint256 category5Jackpot;        
        uint256 lastTicketId;
        uint256 endTime;
        _lotteries[currentLotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            endTime: 0,
            firstTicketId: currentTicketId,
            transferJackpot: fundJackpot,
            category1Jackpot: (_lotteries[currentLotteryId].category1Jackpot).add((fundJackpot.mul(CATEGORY_1_PCT)).div(100)),
            category2Jackpot: (_lotteries[currentLotteryId].category2Jackpot).add((fundJackpot.mul(CATEGORY_2_PCT)).div(100)),
            category3Jackpot: (_lotteries[currentLotteryId].category3Jackpot).add((fundJackpot.mul(CATEGORY_3_PCT)).div(100)),
            category4Jackpot: (_lotteries[currentLotteryId].category4Jackpot).add((fundJackpot.mul(CATEGORY_4_PCT)).div(100)),
            category5Jackpot: (_lotteries[currentLotteryId].category5Jackpot).add((fundJackpot.mul(CATEGORY_5_PCT)).div(100)),
            winningNumbers: [uint(0), uint(0), uint(0), uint(0), uint(0), uint(0)],
            lastTicketId: currentTicketId,
            c1Winners: 0,
            c2Winners: 0,
            c3Winners: 0,
            c4Winners: 0,
            c5Winners: 0
        });
        emit LotteryOpen(
            currentLotteryId,
            block.timestamp,
            endTime,
            ticketPrice,
            currentTicketId,
            transferJackpot,
            category1Jackpot,
            category2Jackpot,
            category3Jackpot,
            category4Jackpot,
            category5Jackpot,
            lastTicketId
        );
        contractLive = true;
    }

/**
##############################################################################################
 */

    
    function buyTickets(address recipient, uint[6] calldata numbers) public payable nonReentrant {
        uint256 walletBalance = paytoken.balanceOf(msg.sender);
        require(walletBalance >= ticketPrice, "Not Enough Funds");
        require(numbers.length == 6, "Invalid number of selected numbers");
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        require(msg.value == fee, "Wrong Amount");
        uint256 lottoShare = (ticketPrice.mul(80)).div(100);
        uint256 ownerShare = (ticketPrice.mul(20)).div(100);

        paytoken.transferFrom(address(msg.sender), address(this), lottoShare);
        paytoken.transferFrom(address(msg.sender), address(ownersFeeWallet), ownerShare);

        _lotteries[currentLotteryId].category1Jackpot += ((lottoShare.mul(CATEGORY_1_PCT)).div(100));
        _lotteries[currentLotteryId].category2Jackpot += ((lottoShare.mul(CATEGORY_2_PCT)).div(100));
        _lotteries[currentLotteryId].category3Jackpot += ((lottoShare.mul(CATEGORY_3_PCT)).div(100));
        _lotteries[currentLotteryId].category4Jackpot += ((lottoShare.mul(CATEGORY_4_PCT)).div(100));
        _lotteries[currentLotteryId].category5Jackpot += ((lottoShare.mul(CATEGORY_5_PCT)).div(100));

        _userTicketIdsPerLotteryId[msg.sender][currentLotteryId].push(currentTicketId);

        _tickets[currentTicketId] = Ticket({
            ticketId:currentTicketId, 
            owner: recipient, 
            chooseNumbers: numbers, 
            status: TicketStatus.NoWinner,
            winAmount: 0
            });
        currentTicketId++;
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        emit TicketsPurchase(msg.sender, currentLotteryId, numbers);
    }

/**
##############################################################################################
 */

    function closeLottery() external {
        require(msg.sender == owner() || msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
        require(_lotteries[currentLotteryId].status == Status.Open, "Lottery not open");
        _lotteries[currentLotteryId].lastTicketId = currentTicketId;
        _lotteries[currentLotteryId].status = Status.Close;
        _lotteries[currentLotteryId].endTime = block.timestamp;

        /**
        Request Id Stores the ChainLink VRF request Id, this is fetched once we execute the drawNumbers()
        and from there we will obtain a random number that we can use to obtain the winning numbers.
        */

        uint256 requestId;
  
        /**
        Lets finally call ChainLink VRFv2 and obtain the winning numbers from the randomness generator.
         */

        requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        lastRequestId = requestId;
        emit LotteryClose(currentLotteryId, currentTicketId);
    }

/**
##############################################################################################
 */

   function drawNumbers() external nonReentrant () {
        require(msg.sender == owner() || msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
        require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
        uint256[] memory numArray = s_requests[lastRequestId].randomWords;
        uint[6] memory finalNumbers;

        for (uint i = 0; i < numArray.length && i < finalNumbers.length; i++) {
            finalNumbers[i] = numArray[i] % 10;
        }

        _lotteries[currentLotteryId].winningNumbers = finalNumbers;

        emit NumbersDrawn(numArray, finalNumbers);
    }

    // Function to test winner allocations ( To be removed in production )
    function setWinnerNumber(uint[6] calldata _manualnumbers) external {
        _lotteries[currentLotteryId].winningNumbers = _manualnumbers;        
    }

    function countWinners() external returns (bool) {
       require(msg.sender == owner() || msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
       require(_lotteries[currentLotteryId].status == Status.Close, "Lottery not close");
       require(_lotteries[currentLotteryId].status != Status.Claimable, "Lottery Already Counted");
       
       delete cat1Winners;
       delete cat2Winners;
       delete cat3Winners;
       delete cat4Winners;
       delete cat5Winners;
       
       uint256 firstTicketId = _lotteries[currentLotteryId].firstTicketId;
       uint256 lastTicketId = _lotteries[currentLotteryId].lastTicketId;
       uint[6] memory winOrder = _lotteries[currentLotteryId].winningNumbers;
       
        for (uint256 i = firstTicketId; i < lastTicketId; i++) {
           uint[6] memory userNum = _tickets[i].chooseNumbers;
           uint256 player = _tickets[i].ticketId;
           uint256 matchCount = 0;
           
           for (uint256 j = 0; j < 6; j++) {
               if (userNum[j] == winOrder[j]) {
                   matchCount++;
                   } else {
                       break; // Exit the loop at the first mismatch
                       }
           }
        
            if (matchCount == 6) {
                cat5Winners++;
                _lotteries[currentLotteryId].c5Winners.add(player);
                _tickets[i].status = TicketStatus.Category5;

            } else if (matchCount == 5) {
                cat4Winners++;
                _lotteries[currentLotteryId].c4Winners.add(player);
                _tickets[i].status = TicketStatus.Category4;

            } else if (matchCount == 4) {
                cat3Winners++;
                _lotteries[currentLotteryId].c3Winners.add(player);
                _tickets[i].status = TicketStatus.Category3;

            } else if (matchCount == 3) {
                cat2Winners++;
                _lotteries[currentLotteryId].c2Winners.add(player);
                _tickets[i].status = TicketStatus.Category2;

            } else if (matchCount == 2) {
                cat1Winners++;
                _lotteries[currentLotteryId].c1Winners.add(player);
                _tickets[i].status = TicketStatus.Category1;
            }
        }
        uint256 cat1prize = cat1Winners > 0 ? _lotteries[currentLotteryId].category1Jackpot.div(cat1Winners) : 0;
        uint256 cat2prize = cat2Winners > 0 ? _lotteries[currentLotteryId].category2Jackpot.div(cat2Winners) : 0;
        uint256 cat3prize = cat3Winners > 0 ? _lotteries[currentLotteryId].category3Jackpot.div(cat3Winners) : 0;
        uint256 cat4prize = cat4Winners > 0 ? _lotteries[currentLotteryId].category4Jackpot.div(cat4Winners) : 0;
        uint256 cat5prize = cat5Winners > 0 ? _lotteries[currentLotteryId].category5Jackpot.div(cat5Winners) : 0;
        for (uint256 i = firstTicketId; i < lastTicketId; i++) {
            if (_tickets[i].status == TicketStatus.Category5) {
                _tickets[i].winAmount = cat5prize;
                winningDebt += cat5prize;
            } else if (_tickets[i].status == TicketStatus.Category4) {
                _tickets[i].winAmount = cat4prize;
                winningDebt += cat4prize;
            } else if (_tickets[i].status == TicketStatus.Category3) {
                _tickets[i].winAmount = cat3prize;
                winningDebt += cat3prize;
            } else if (_tickets[i].status == TicketStatus.Category2) {
                _tickets[i].winAmount = cat2prize;
                winningDebt += cat2prize;
            } else if (_tickets[i].status == TicketStatus.Category1) {
                _tickets[i].winAmount = cat1prize;
                winningDebt += cat1prize;
            }
        }  
    _lotteries[currentLotteryId].status = Status.Claimable;
    emit WinnersCounted(
        cat1Winners,
        cat2Winners,
        cat3Winners,
        cat4Winners,
        cat5Winners,
        cat1prize,
        cat2prize,
        cat3prize,
        cat4prize,
        cat5prize
    );
    return false;
    }

    function claim(uint256 ticketId) public nonReentrant () {        
        require(_tickets[ticketId].owner == msg.sender, "Not the owner of the ticket");
        require(_tickets[ticketId].status != TicketStatus.NoWinner, "Ticket has no winning prize");
        uint256 winningAmount = _tickets[ticketId].winAmount;
        require(winningAmount > 0, "Ticket has no winning amount");
        paytoken.safeTransfer(address(msg.sender), winningAmount);
        winningsPaid += winningAmount;
        winningDebt -= winningAmount;
        _tickets[ticketId].status = TicketStatus.Claimed;
        emit TicketClaimed(ticketId, msg.sender, winningAmount);
    }

/**
##############################################################################################
 */

   /**
   Chainlink VRFv2 Specific functions required in the smart contract for full functionality.
    */

    function getRequestStatus(
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[lastRequestId].exists, "request not found");
        RequestStatus memory request = s_requests[lastRequestId];
        return (request.fulfilled, request.randomWords);
    }


    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
    }

    /**
    Lottery additional functions.
     */

    function viewLottery(uint256 _lotteryId) external view returns (Lottery memory) {
        return _lotteries[_lotteryId];
    }

    function viewTicket(uint256 ticketId) external view returns (address, uint[6] memory, TicketStatus, uint256) {
        return (_tickets[ticketId].owner, _tickets[ticketId].chooseNumbers, _tickets[ticketId].status, _tickets[ticketId].winAmount);
    }


    function viewTicketsCurrentLottery(address _address) external view returns (Ticket[] memory) {
        uint256[] memory ticketIds = _userTicketIdsPerLotteryId[_address][currentLotteryId];
        uint256 numTickets = ticketIds.length;
        Ticket[] memory tickets = new Ticket[](numTickets);

        for (uint256 i = 0; i < numTickets; i++) {
            tickets[i] = _tickets[ticketIds[i]];
        }

        return tickets;
    }

    function viewTicketsPreviousLotteries(address _address, uint256 _toCheck) external view returns (Ticket[][] memory) {
        uint256 numLotteriesToCheck = _toCheck;
        uint256 startingLotteryId = currentLotteryId > numLotteriesToCheck ? currentLotteryId - numLotteriesToCheck : 0;
        uint256[][] memory ticketIds = new uint256[][](numLotteriesToCheck);
        Ticket[][] memory tickets = new Ticket[][](numLotteriesToCheck);

        for (uint256 i = 0; i < numLotteriesToCheck; i++) {
            uint256 lotteryId = startingLotteryId + i;
            uint256[] memory userTicketIds = _userTicketIdsPerLotteryId[_address][lotteryId];
            uint256 numTickets = userTicketIds.length;
            ticketIds[i] = new uint256[](numTickets);
            tickets[i] = new Ticket[](numTickets);

            for (uint256 j = 0; j < numTickets; j++) {
                ticketIds[i][j] = userTicketIds[j];
                tickets[i][j] = _tickets[userTicketIds[j]];
            }
        }

        return tickets;
    }
    
    function getBalance() external view returns(uint256) {
        return paytoken.balanceOf(address(this));
    }

    function fundContract(uint256 amount) external onlyOwner {
        paytoken.safeTransferFrom(address(msg.sender), address(this), amount);
    }

    function withdraw() public onlyOwner() {
        require (contractLive == false, "Contract still Live");
        paytoken.safeTransfer(address(msg.sender), (paytoken.balanceOf(address(this)) - winningDebt));
    }

    function setTicketPrice(uint256 newPrice) public onlyOwner {
        ticketPrice = newPrice;
    }

    function setOwnersFeeWallet(address _ownersFeeWallet) public onlyOwner {
        ownersFeeWallet = _ownersFeeWallet;
    }

    function setContractLive(bool _contractLive) public {
        require(msg.sender == owner() || msg.sender == factoryWallet, "Not allowed");
        contractLive = _contractLive;
    }

    function setWebsiteAddress(string memory _address) public {
        require(msg.sender == owner() || msg.sender == factoryWallet, "Not allowed");
        websiteAddress = _address;
    }

    function setLotteryFee(uint256 _lotteryFee) public {
        require(msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
        fee = _lotteryFee;
    }

    function withdrawFees() public {
        require(msg.sender == factoryWallet || msg.sender == factoryContract, "Not allowed");
        payable(msg.sender).transfer(address(this).balance);
    }
}