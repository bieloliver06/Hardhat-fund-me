// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();

//constant and immutable
contract FundMe {
  using PriceConverter for uint256;

  uint256 public constant MINIMUM_USD = 10 * 1e18;

  address[] public funders;
  mapping(address => uint256) public addressToAmountFunded;

  address public immutable i_owner;

  AggregatorV3Interface public priceFeed;

  constructor(address priceFeedAddress) {
    i_owner = msg.sender;
    priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  function fund() public payable {
    require(
      msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
      "Didn't send enough..."
    );
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] = msg.value;
  }

  function withdraw() public onlyOwner {
    for (
      uint256 funderIndex = 0;
      funderIndex < funders.length;
      funderIndex = funderIndex++
    ) {
      address funder = funders[funderIndex];
      addressToAmountFunded[funder] = 0;
    }

    funders = new address[](0);

    //bool sendSuccess = payable(msg.sender).send(address(this).balance);
    //require(sendSuccess, "Send failed");

    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    require(callSuccess, "Call failed");
  }

  modifier onlyOwner() {
    // require(msg.sender == i_owner, "You aren't the owner...");
    if (msg.sender != i_owner) {
      revert NotOwner();
    }
    _;
  }

  // What happens if someone sends this contract ETH without calling the fund call

  // receive()
  // fallback()

//  receive() external payable {
//    fund();
//  }

//  fallback() external payable {
//    fund();
//  }
}
