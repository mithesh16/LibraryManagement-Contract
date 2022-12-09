//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;


import "@openzeppelin/contracts/access/Ownable.sol";

contract Library is Ownable{
    
    uint public bookIndex;
    uint public userscount;
    struct Book{
            uint bookId;
            string bookName;
            string authorName;
            bool rented;
            uint startdate;
            address current;
            uint price;
            address payable owner;
        }
    struct User{
            uint userId;
            string username;
            bool eligible;
        }
    mapping(uint=>Book) public books;
    mapping(address=>User) public users;
    mapping(address=>Book) public booktrack;

    function addBook(string memory _bookname,string memory _authorname,uint _price)public onlyOwner{
        bookIndex++;
        books[bookIndex]=Book(
            bookIndex,
            _bookname,
            _authorname,
            false,
            0,
            address(0),
            _price,
            payable(msg.sender)
            );
        }

    function addUser(string memory _name) public {
        userscount++;
        users[msg.sender]=User(userscount,_name,true);
    }
     function rentBook(uint _index) public{
           Book storage book=books[_index];
           User storage lender=users[msg.sender];
           require(!book.rented,"Book already rented");
           require(lender.eligible,"User not eligible to rent");
           book.rented=true;
           book.current=msg.sender;
           book.startdate=block.timestamp/60/60/24;
           lender.eligible=false;
           booktrack[msg.sender]=book;     
     }
    function returnbook(uint _index,uint _userid) public payable {
        Book storage book=books[_index];
        User storage lender=users[msg.sender];
        require(_userid==lender.userId,"User not found");
        require(book.rented,"Book not rented");
        uint totalfee=book.price*(block.timestamp - book.startdate);
        require(msg.value>=totalfee,"Not enough fee");
        book.owner.transfer(msg.value);
        book.rented=false;
        book.current=address(0);
        book.startdate=0;
        lender.eligible=true;
    }
    function deletebook(uint bookid) public onlyOwner{
        require(!books[bookid].rented,"Book currently rented");
        delete books[bookid];
    }
    

    }                  
            
            