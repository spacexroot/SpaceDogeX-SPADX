// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract SpacedogexToken {
    bool private _initialized;
    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public liquidityWallet;
    address public feeWallet;
    uint256 public feePercent;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier initializer() {
        require(!_initialized);
        _;
        _initialized = true;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply,
        address liquidity_,
        address fee_,
        uint256 feeP_
    ) public initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        liquidityWallet = liquidity_;
        feeWallet = fee_;
        feePercent = feeP_;
        _mint(msg.sender, initialSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0));
        require(recipient != address(0));
        uint256 fee = amount * feePercent / 10000;
        uint256 amountAfterFee = amount - fee;
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amountAfterFee;
        uint256 feeHalf = fee / 2;
        _balances[liquidityWallet] = _balances[liquidityWallet] + feeHalf;
        _balances[feeWallet] = _balances[feeWallet] + (fee - feeHalf);
        emit Transfer(sender, recipient, amountAfterFee);
        if(fee > 0) {
            emit Transfer(sender, liquidityWallet, feeHalf);
            emit Transfer(sender, feeWallet, fee - feeHalf);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
