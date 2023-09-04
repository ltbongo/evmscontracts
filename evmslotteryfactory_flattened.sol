
// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

// File: @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol


pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// File: @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: EVMS/evmslottery.sol


pragma solidity ^0.8.0;







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
// File: EVMS/evmslotteryfactory.sol


pragma solidity ^0.8.19;






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