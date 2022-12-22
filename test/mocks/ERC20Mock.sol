pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "solidity-erc20/ERC20.sol";

contract ERC20Mock is ERC20 {
    function mint(address recipient, uint256 amount) public {
        _mint(recipient, amount);
    }

    function burn(address owner, uint256 amount) public {
        _burn(owner, amount);
    }
}
