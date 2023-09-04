// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./evmslottery.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// test token : 0x014d7E61De369Edd309295dbc9b0fa78fE7F0647
//  test token2 : 0xDc98a806F0ed6F6aaFf16FA75efa6917485E18FF

contract EVMSLotteryFactory is Ownable, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;
    
    // Bsc Testnet Chainlink Contract Addresses for VRF and Upkeeps.
    address public vrfCoordinator = 0x6A2AAd07396B36Fe02a22b33cf443582f682c82f;
    address public link_token_contract = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
    bytes32 public keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
    address public closeUpkeep = 0xB7bb9D0BE947e1Ea3d83ae09aBf9FE88515237ac;
    address public drawUpkeep = 0x335a93F3032036f6f56D5ecE4Ff15198B2294e5D;
    address public countUpkeep = 0x0795ae5ffF71f63d595f6f0992C545cC8289a4B0;
    address public openUpkeep = 0x0795ae5ffF71f63d595f6f0992C545cC8289a4B0;
    uint32 public callbackGasLimit = 100000;
    uint64 public s_subscriptionId;
    uint64 public _subscriptionId = s_subscriptionId;
    bytes32 public _keyHash = keyHash;
    address public _vrfCoordinator = vrfCoordinator;
    address public _factoryWallet = 0xB61b49e475641F943FcA7980CC148f5466d632cD;
    address public _factoryContract;
    address public s_owner;
    uint256[] public s_randomWords;
    address[] public deployedLotteries;
    uint256 public totalContractsCreated;
    uint256 public fee = 1 ether;
    
    
    event LotteryContractCreated(address Creator, address LotteryContract);

    mapping(address => mapping(uint256 => address)) public registry;
    mapping(address => uint256) public createdContractsByAddress;

    constructor() VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link_token_contract);
        s_owner = msg.sender;
        _factoryContract = address(this);
        //Create a new subscription when you deploy the contract.
        createNewSubscription();
    }

    function setCloseUpkeep(address _closeUpkeepAddress) public onlyOwner {
        closeUpkeep = _closeUpkeepAddress;
    }

    function setDrawUpkeep(address _drawUpkeepAddress) public onlyOwner {
        drawUpkeep = _drawUpkeepAddress;
    }

    function setCountUpkeep(address _countUpkeepAddress) public onlyOwner {
        countUpkeep = _countUpkeepAddress;
    }

    function setOpenUpkeep(address _openUpkeepAddress) public onlyOwner {
        openUpkeep = _openUpkeepAddress;
    }

    function createNewSubscription() private onlyOwner {
        s_subscriptionId = COORDINATOR.createSubscription();
        // Add this contract as a consumer of its own subscription.
        COORDINATOR.addConsumer(s_subscriptionId, address(this));
        _subscriptionId = s_subscriptionId;
    }

    function topUpSubscription(uint256 amount) external onlyOwner {
        LINKTOKEN.transferAndCall(
            address(COORDINATOR),
            amount,
            abi.encode(s_subscriptionId)
        );
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function createLottery(
        IERC20 _paytoken,
        uint256 _ticketPrice,
        address _ownersFeeWallet
    ) public payable returns (address newlotteryContract) {
        require(msg.value == fee, "Wrong Amount");
        evmslottery lottery = new evmslottery(vrfCoordinator);
        evmslottery(lottery).initialize(
            _subscriptionId,
            _paytoken,
            _ticketPrice,
            _keyHash,
            _ownersFeeWallet,
            _factoryWallet,
            _factoryContract
        );
        evmslottery(lottery).transferOwnership(msg.sender);
        registry[msg.sender][
            createdContractsByAddress[msg.sender]
        ] =  address(lottery);
        createdContractsByAddress[msg.sender]++;
        deployedLotteries.push(address(lottery));
        totalContractsCreated++;
        COORDINATOR.addConsumer(s_subscriptionId, address(lottery));
        emit LotteryContractCreated(msg.sender, address(lottery));
        return address(lottery);
    }

    function addConsumer(address consumerAddress) external onlyOwner {
        // Add a consumer contract to the subscription.
        COORDINATOR.addConsumer(s_subscriptionId, consumerAddress);
    }

    function removeConsumer(address consumerAddress) external onlyOwner {
        // Remove a consumer contract from the subscription.
        COORDINATOR.removeConsumer(s_subscriptionId, consumerAddress);
    }

    function cancelSubscription(address receivingWallet) external onlyOwner {
        // Cancel the subscription and send the remaining LINK to a wallet address.
        COORDINATOR.cancelSubscription(s_subscriptionId, receivingWallet);
        s_subscriptionId = 0;
    }

    // Transfer this contract's funds to an address.
    // 1000000000000000000 = 1 LINK
    function withdraw(uint256 amount, address to) external onlyOwner {
        LINKTOKEN.transfer(to, amount);
    }

    function getDeployedLotteries() public view returns (address[] memory) {
        return deployedLotteries;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function withdrawFees() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function owner() public view override(Ownable) returns (address) {
        return super.owner();
    }

    function renounceOwnership() public override(Ownable) onlyOwner {
        Ownable.renounceOwnership();
    }

    function transferOwnership(address newOwner) public override(Ownable) onlyOwner {
        Ownable.transferOwnership(newOwner);
    }

    function closeAllLotteries() public {
        require(msg.sender == owner() || msg.sender == closeUpkeep, "Not allowed to call this function");
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            if (lottery.contractLive()) {
                closeLottery(deployedLotteries[i]);
            }
        }
    }

    function closeLottery(address lotteryAddress) internal {
        evmslottery lottery = evmslottery(lotteryAddress);
        lottery.closeLottery();
    }

    function  drawAllLotteries() public {
        require(msg.sender == owner() || msg.sender == drawUpkeep, "Not allowed to call this function");
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            if (lottery.contractLive()) {
                drawNumbers(deployedLotteries[i]);
            }
        }
    }

    function drawNumbers(address lotteryAddress) internal {
        evmslottery lottery = evmslottery(lotteryAddress);
        lottery.drawNumbers();
    }

    function  countAllWinners () public {
        require(msg.sender == owner() || msg.sender == countUpkeep, "Not allowed to call this function");
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            if (lottery.contractLive()) {
                countWinners(deployedLotteries[i]);
            }
        }
    }

    function countWinners(address lotteryAddress) internal {
        evmslottery lottery = evmslottery(lotteryAddress);
        lottery.countWinners();
    }

    function  openAllLotteries () public {
        require(msg.sender == owner() || msg.sender == openUpkeep, "Not allowed to call this function");
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            if (lottery.contractLive()) {
                openLottery(deployedLotteries[i]);
            }
        }
    }

    function openLottery(address lotteryAddress) internal {
        evmslottery lottery = evmslottery(lotteryAddress);
        lottery.openLottery();
    }

    function setAllLotteryFees(uint256 _lotteryFee) public onlyOwner {
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            lottery.setLotteryFee(_lotteryFee);
        }
    }

    function withdrawAllFees() public onlyOwner {
        for (uint256 i = 0; i < deployedLotteries.length; i++) {
            evmslottery lottery = evmslottery(deployedLotteries[i]);
            lottery.withdrawFees();
        }
    }


}