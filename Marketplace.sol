// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Marketplace{
    address[] public SellersList;
    enum DealStatus {Paid, Completed , Cancelled}
    struct product{
        string ProductName;
        uint ProductPrice;
    }
    struct deal{
        address SellerAddress;
        address BuyerAddress;
        uint Value;
        DealStatus Status;
    }
    modifier OnlySeller{
        bool check = false;
        for(uint i = 0; i < SellersList.length;i++){
            if (msg.sender == SellersList[i]){
                check = true;
            }
        }
        require(check, "You are not a seller");
        _;
    }
    function IsSeller(address abc) public view returns(bool){
        bool check = false;
        for(uint i = 0; i < SellersList.length;i++){
            if (abc == SellersList[i]){
                check = true;
            }
        }
        return check;
    }
    function OnlyBuyer(address abc) public view returns(bool){
        bool check = true;
        for(uint i = 0; i < SellersList.length;i++){
            if (abc == SellersList[i]){
                check = false;
            }
        }
        return check;
    }
    mapping (address Seller => product[] ListOfProducts) public SellerToProductMapping;
    mapping (address Buyer => deal[]) internal BuyerToDeal;
    mapping (address Seller => deal[]) internal SellerToDeal;
    function NewSeller() public{
        SellersList.push(msg.sender);
    }
    function ListProduct(string memory ProductName , uint ProductPrice ) public OnlySeller{
        SellerToProductMapping[msg.sender].push(product(ProductName,ProductPrice));
    }
    function buy(address SellersAddress, uint ProductIndex) public payable {
        require(OnlyBuyer(msg.sender), "Seller are not allowed to buy");
        require(IsSeller(SellersAddress),"The seller does not exist");
        require(ProductIndex < SellerToProductMapping[SellersAddress].length);
        require(msg.value == SellerToProductMapping[SellersAddress][ProductIndex].ProductPrice, "Please pay the correct amount");
        BuyerToDeal[msg.sender].push(deal(SellersAddress, msg.sender, msg.value, DealStatus.Paid));
        SellerToDeal[SellersAddress].push(deal(SellersAddress, msg.sender, msg.value, DealStatus.Paid));
    }
    function CancelDealSeller(uint DealIndex) public OnlySeller{
        SellerToDeal[msg.sender][DealIndex].Status = DealStatus.Cancelled;
    }
    function CompleteDeal(uint DealIndex) public{
        require(OnlyBuyer(msg.sender), "Seller cannot complete deal");
        BuyerToDeal[msg.sender][DealIndex].Status = DealStatus.Completed;
    }
    function SellerWithdraw(uint DealIndex) public OnlySeller{
        require(SellerToDeal[msg.sender][DealIndex].Status == DealStatus.Completed, "The deal is not completed yet");
        (bool CallSuccess,) = payable(msg.sender).call{value: SellerToDeal[msg.sender][DealIndex].Value}("");
        require(CallSuccess,"Failed");
    }
    function BuyerWithdraw(uint DealIndex) public {
        require(OnlyBuyer(msg.sender), "Your are not buyer");
        require(BuyerToDeal[msg.sender][DealIndex].Status == DealStatus.Cancelled, "The deal is ongoing");
        (bool CallSuccess,) = payable(msg.sender).call{value: BuyerToDeal[msg.sender][DealIndex].Value}("");
        require(CallSuccess,"Failed");
    }
}



























