//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract HouseRental is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _totalAppartments;

    struct ApartmentStruct {
        uint256 id;
        string name;
        string description;
        string location;
        string images;
        uint256 rooms;
        uint256 price;
        address owner;
        bool booked;
        bool deleted;
        uint256 timestamp;
    }

    struct BookingStruct {
        uint256 id;
        uint256 aid;
        address tenant;
        uint256 date;
        uint256 price;
        bool checked;
        bool cancelled;
    }

    struct ReviewStruct {
        uint256 id;
        uint256 aid;
        string reviewText;
        uint256 timestamp;
        address owner;
    }

    uint256 public securityFee;
    uint256 public taxPercent;

    mapping(uint256 => ApartmentStruct) apartments;
    mapping(uint256 => BookingStruct[]) bookingsOf;
    mapping(uint256 => ReviewStruct[]) reviewsOf;
    mapping(uint256 => bool) apartmentExists;
    mapping(uint256 => uint256[]) bookedDates;
    mapping(uint256 => mapping(uint256 => bool)) isDateBooked;
    mapping(address => mapping(uint256 => bool)) hasBooked;

    constructor(uint256 _taxPercent, uint256 _securityFee) {
        taxPercent = _taxPercent;
        securityFee = _securityFee;
    }

    function createApartment(
        string memory name,
        string memory description,
        string memory location,
        string memory images,
        uint256 rooms,
        uint256 price
    ) public {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(location).length > 0, "Location can not be empty");
        require(bytes(images).length > 0, "Images cannot be empty");
        require(rooms > 0, "Rooms cannot be zero");
        require(price > 0 ether, "Price cannot be zero");

        _totalAppartments.increment();

        ApartmentStruct memory apartment;
        apartment.id = _totalAppartments.current();
        apartment.name = name;
        apartment.description = description;
        apartment.location = location;
        apartment.images = images;
        apartment.rooms = rooms;
        apartment.price = price;
        apartment.owner = msg.sender;
        apartment.timestamp = currentTime();

        apartmentExists[apartment.id] = true;
        apartments[apartment.id] = apartment;
    }

    function updateApartment(
        uint256 id,
        string memory name,
        string memory description,
        string memory location,
        string memory images,
        uint256 rooms,
        uint256 price
    ) public {
        require(apartmentExists[id], "Apartment not found");
        require(msg.sender == apartments[id].owner, "Unauthorised enitity");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(location).length > 0, "Location can not be empty");
        require(bytes(images).length > 0, "Images cannot be empty");
        require(rooms > 0, "Rooms cannot be zero");
        require(price > 0 ether, "Price cannot be zero");

        ApartmentStruct memory apartment = apartments[id];
        apartment.name = name;
        apartment.description = description;
        apartment.location = location;
        apartment.images = images;
        apartment.rooms = rooms;
        apartment.price = price;

        apartments[apartment.id] = apartment;
    }


    function deleteApartment(uint256 id) public {
        require(apartmentExists[id], "Apartment not found");
        require(msg.sender == apartments[id].owner, "Unauthorized action");

        apartmentExists[id] = false;
        apartments[id].deleted = true;
    }


    function getApartment(uint256 id) public view returns(ApartmentStruct memory) {
        return apartments[id];
    }

    function getApartments() public view returns(ApartmentStruct[] memory Apartments) {
        uint256 available;
        for(uint256 i = 1; i <= _totalAppartments.current(); i++) {
            if(!apartments[i].deleted) available++;
        }

        Apartments = new ApartmentStruct[](available);

        uint256 index;
        for(uint256 i = 1; i < _totalAppartments.current(); i ++) {
            if(!apartments[i].deleted) {
                Apartments[index++] = apartments[i];
                index++;
            }
        }
    }



    function bookApartment(uint256 aid, uint256[] memory dates) public payable {
        uint256 totalPrice = apartments[aid].price * dates.length;
        uint256 totalSecuityFee = (totalPrice * securityFee) / 100;

        require(apartmentExists[aid], "Apartment not found");
        require(msg.value >= (totalPrice + totalSecuityFee), "Insufficient balance");
        require(datesChecker(aid, dates), "Date not available");

        for(uint256 i = 0; i < dates.length; i++) {
            BookingStruct memory booking;
            booking.id = bookingsOf[aid].length;
            booking.aid = aid;
            booking.tenant = msg.sender;
            booking.date = dates[i];
            booking.price = apartments[aid].price;

            bookingsOf[aid].push(booking);
            bookedDates[aid].push(dates[i]); 
            isDateBooked[aid][dates[i]] = true;
            // hasBooked[msg.sender][dates[i]] = true;
        }


    }

    function checkInApartment(uint256 aid, uint256 bookingId) public nonReentrant() {
        BookingStruct memory booking = bookingsOf[aid][bookingId];
        require(msg.sender == booking.tenant, "Unauthorized entity");
        require(!booking.checked, "Alreadt checked in");

        bookingsOf[aid][bookingId].checked = true;
        hasBooked[msg.sender][booking.date] = true;

        uint256 tax = (booking.price * taxPercent) / 100;
        uint256 fee = (booking.price * securityFee) / 100;

        payTo(apartments[aid].owner, booking.price - tax);
        payTo(owner(), tax);
        payTo(booking.tenant, fee);
    }

    function refundBooking(uint256 aid, uint256 bookingId) public nonReentrant() {
       BookingStruct memory booking = bookingsOf[aid][bookingId];
       require(!booking.checked, "Alreadt checked in");
       require(isDateBooked[aid][booking.date], "Date not booked");

       if(msg.sender != owner()) {
        require(msg.sender == booking.tenant, "Unauthorized entity");
        require(booking.date > currentTime(), "Not allowed, exceeded booking date");

       }

       bookingsOf[aid][bookingId].cancelled = true;
       isDateBooked[aid][booking.date] = false;

       uint256 lastIndex = bookedDates[aid].length - 1;
       uint256 lastBooking = bookedDates[aid][lastIndex];

       bookedDates[aid][bookingId] = lastBooking;
       bookedDates[aid].pop();

        uint256 fee = (booking.price * securityFee) / 100;
        uint256 collateral = fee / 2;

        payTo(apartments[aid].owner, collateral);
        payTo(owner(), collateral);
        payTo(booking.tenant, booking.price);
    }


    function claimFunds(uint256 aid, uint256 bookingId) public {
        BookingStruct memory booking = bookingsOf[aid][bookingId];

        require(msg.sender == apartments[aid].owner || msg.sender == owner(), "Unauthorized entity");
        require(!booking.checked, "Already checked in");
        require(booking.date < currentTime(), "Not allowed, booking date not exceeded");


        uint256 tax = (booking.price * taxPercent) / 100;
        uint256 fee = (booking.price * securityFee) / 100;

        payTo(apartments[aid].owner, booking.price - tax);
        payTo(owner(), tax);
        payTo(booking.tenant, fee);
    }


    function getBooking(uint256 aid, uint256 bookingId) public view returns(BookingStruct memory) {
        return bookingsOf[aid][bookingId];
    }
    function getBookings(uint256 aid) public view returns(BookingStruct[] memory) {
        return bookingsOf[aid];
    }

    function getUnavailableDates(uint256 aid) public view returns(uint256[] memory) {
        return bookedDates[aid];
    }


    function addReview(uint256 aid, string memory comment) public {
        require(apartmentExists[aid], "Appartment not found");
        require(hasBooked[msg.sender][aid], "Book first before review");
        require(bytes(comment).length > 0, "Comment can not be empty");

        ReviewStruct memory review;
        review.id = reviewsOf[aid].length;
        review.aid = aid;
        review.reviewText = comment;
        review.owner = msg.sender;
        review.timestamp = currentTime();

        reviewsOf[aid].push(review);
    }

    function getReviews(uint256 aid) public view returns(ReviewStruct[] memory) {
        return reviewsOf[aid];
    }

    function getQualifiedReviewers(uint256 aid) public view returns(address[] memory Tenants) {
        uint256 available;
        for(uint256 i = 0; i < bookingsOf[aid].length; i++) {
            if(bookingsOf[aid][i].checked) available++;
        }

        Tenants = new address[](available);
        uint256 index;
        for(uint256 i = 0; i < bookingsOf[aid].length; i++) {
            if(bookingsOf[aid][i].checked)  {
                Tenants[index++] = bookingsOf[aid][i].tenant;
            }
        }

    }

    function tenantBooked(uint256 aid) public view returns(bool) {
        return hasBooked[msg.sender][aid];
    }

    function datesChecker(uint256 aid, uint256[] memory dates) internal view returns(bool) {
        bool dateNotUsed = true;

        for(uint256 i = 0; i < dates.length; i++) {
            for(uint256 j = 0; j < bookedDates[aid].length; j++) {
                if(dates[i] == bookedDates[aid][j]) {
                    dateNotUsed = false;
                }
            }
        }

        return dateNotUsed;
    }

    function currentTime() internal view returns (uint256) {
        return (block.timestamp * 1000) + 1000;
    }

    function payTo(address to, uint256 amount) internal {
        (bool success,) = payable(to).call{value: amount}('');
        require(success);
    }
}
