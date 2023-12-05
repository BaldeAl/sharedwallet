// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import "../../src/sharedAccount/SharedAccount.sol";

contract SharedAccountTest is Test {
    SharedAccount sharedAccount;
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        sharedAccount = new SharedAccount(user1, user2);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    // Test pour le deposit
    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        vm.prank(user1);
        sharedAccount.deposit{value: depositAmount}();

        assertEq(sharedAccount.getSharedBalance(), depositAmount);
    }

    // Test pour le cas d'erreur dans approveWithdrawal
    function testRequestAndApproveWithdrawal() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawalAmount = 0.5 ether;
        address payable withdrawalDestination = payable(address(0x789));

        vm.prank(user2);
        sharedAccount.deposit{value: depositAmount}();

        vm.prank(user1);
        sharedAccount.requestWithdrawal(
            withdrawalAmount,
            withdrawalDestination
        );

        (uint256 requestedAmount, address destination) = sharedAccount
            .getPendingWithdrawal(user1);
        assertEq(requestedAmount, withdrawalAmount);
        assertEq(destination, withdrawalDestination);

        vm.prank(user2);
        sharedAccount.approveWithdrawal(user1);

        assertGt(address(0x789).balance, 0);

        assertEq(
            sharedAccount.getSharedBalance(),
            depositAmount - withdrawalAmount
        );
        assertEq(address(0x789).balance, withdrawalAmount);
    }

    // Test pour le cas d'erreur dans requestWithdrawal
    function testRequestWithdrawalFail() public {
        uint256 withdrawalAmount = 11 ether; // Plus que le solde
        address payable withdrawalDestination = payable(address(0x789));

        vm.prank(user1);
        vm.expectRevert("Solde partage insuffisant");
        sharedAccount.requestWithdrawal(
            withdrawalAmount,
            withdrawalDestination
        );
    }

    // Test pour le cas d'erreur dans approveWithdrawal
    function testApproveWithdrawalFail() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawalAmount = 0.5 ether;
        address payable withdrawalDestination = payable(address(0x789));

        vm.prank(user2);
        sharedAccount.deposit{value: depositAmount}();

        vm.prank(user1);
        sharedAccount.requestWithdrawal(
            withdrawalAmount,
            withdrawalDestination
        );

        vm.prank(user1); // User1 tente d'approuver son propre retrait
        vm.expectRevert("Ne peut pas approuver son propre retrait");
        sharedAccount.approveWithdrawal(user1);
    }

    // Test des dépôts par un utilisateur non autorisé
    function testUnauthorizedDeposit() public {
        uint256 depositAmount = 1 ether;
        address unauthorizedUser = address(0xABC);

        vm.prank(unauthorizedUser);
        vm.expectRevert();
        sharedAccount.deposit{value: depositAmount}();
    }

    // Test de la demande de retrait avec un montant de 0
    function testRequestWithdrawalWithZeroAmount() public {
        address payable withdrawalDestination = payable(address(0x789));

        vm.prank(user1);
        vm.expectRevert();
        sharedAccount.requestWithdrawal(0, withdrawalDestination);
    }

    // Test de l'approbation de retrait sans retrait en attente
    function testApproveWithdrawalWithoutPending() public {
        vm.prank(user2);
        vm.expectRevert("Pas de retrait en attente");
        sharedAccount.approveWithdrawal(user1);
    }

    function testApproveWithdrawalIncreasesDestinationBalance() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawalAmount = 0.5 ether;
        address payable withdrawalDestination = payable(address(0x789));

        uint256 initialDestinationBalance = withdrawalDestination.balance;

        vm.prank(user1);
        sharedAccount.deposit{value: depositAmount}();

        vm.prank(user2);
        sharedAccount.requestWithdrawal(
            withdrawalAmount,
            withdrawalDestination
        );

        vm.prank(user1);
        sharedAccount.approveWithdrawal(user2);

        uint256 finalDestinationBalance = withdrawalDestination.balance;
        assertEq(
            finalDestinationBalance,
            initialDestinationBalance + withdrawalAmount
        );
    }
}
