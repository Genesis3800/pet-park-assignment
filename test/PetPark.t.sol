// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";


contract PetParkTest is Test, PetPark {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }

    //Making this a fuzz test
    function testCannotAddAnimalWhenNonOwner(address nonOwner) public {
        // 1. Complete this test and remove the assert line below

        vm.prank(nonOwner);
        vm.expectRevert("Only owner can perform this action");
        petPark.add(AnimalType.Fish, 5);
    }

    //This function won't work with the smart contract

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(AnimalType.None, 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        // 2. Complete this test and remove the assert line below

        vm.prank(petPark.owner());
        petPark.add(AnimalType.Fish, 5); 

        vm.expectRevert("Only adults can borrow animals");
        petPark.borrow(0,Gender.Female,AnimalType.Fish);
    }

    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(24, Gender.Male, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Men can borrow only Dog and Fish");
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Men can borrow only Dog and Fish");
        petPark.borrow(24, Gender.Male, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Men can borrow only Dog and Fish");
        petPark.borrow(24, Gender.Male, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Women aged under 40 are not allowed to borrow a Cat");
        petPark.borrow(24, Gender.Female, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Already borrowed an animal. Return first to borrow another.");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

        vm.expectRevert("Already borrowed an animal. Return first to borrow another.");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Age mismatch");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, Gender.Male, AnimalType.Fish);

		vm.expectRevert("Gender mismatch");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, Gender.Female, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(24, Gender.Male, AnimalType.Fish);
    }

    function testBorrowCountDecrement() public {
        // 3. Complete this test and remove the assert line below

        vm.prank(petPark.owner());
        petPark.add(AnimalType.Fish, 5);

        for(uint i =1; i<=5; i++)
        {
            address tempAccount = address(bytes20(uint160((i))));

            vm.prank(tempAccount);
            petPark.borrow(20,Gender.Female,AnimalType.Fish);
            console.log("Fish Left ", petPark.animalCounts(AnimalType.Fish));
        }

        address tempAccount = address(10);

        vm.prank(tempAccount);
        vm.expectRevert("Selected animal not available");
        petPark.borrow(20,Gender.Female,AnimalType.Fish);

    }

    function testCannotGiveBack() public {
        vm.expectRevert("Haven't borrowed any animal.");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(24, Gender.Male, AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(AnimalType.Fish);

		assertEq(reducedPetCount, currentPetCount - 1);
    }
}