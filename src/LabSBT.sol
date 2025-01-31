// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Little Abstract Boops Soulbound Token
 * @notice This contract manages a non-transferable (soulbound) NFT collection
 * @dev Implements ERC721 with transfer restrictions
 */
contract LabSBT is ERC721, Ownable, ReentrancyGuard {
    // Custom errors
    error MintNotActive();
    error InsufficientPayment();
    error InvalidProof();
    error AlreadyClaimed();
    error MaxSupplyReached();
    error TransferFailed();
    error SoulboundTokensNotTransferable();

    // State variables
    bool public activeMint;
    uint256 public mintPrice;
    uint256 public totalSupply;
    bytes32 public merkleRoot;

    // Constants
    uint256 public constant MAX_SUPPLY = 1000;

    // Base URI for token metadata
    string private baseURI;

    // Mapping to track if address has minted
    mapping(address => bool) public hasMinted;

    // Events
    event NFTMinted(address indexed to, uint256 indexed tokenId);
    event MerkleRootUpdated(bytes32 newMerkleRoot);
    event BaseURIUpdated(string newBaseURI);
    event MintPriceUpdated(uint256 newPrice);
    event PaymentWithdrawn(address to, uint256 amount);

    constructor(
        uint256 _mintPrice
    ) ERC721("Little Abstract Boops SBT", "LabSBT") Ownable(msg.sender) {
        mintPrice = _mintPrice;
    }

    /**
     * @dev Override transfer functions to prevent transfers
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        revert SoulboundTokensNotTransferable();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        revert SoulboundTokensNotTransferable();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        revert SoulboundTokensNotTransferable();
    }

    /**
     * @dev Enables or disables minting
     */
    function setActiveMint(bool _activeMint) external onlyOwner {
        activeMint = _activeMint;
    }

    /**
     * @dev Main minting function with whitelist verification
     * @param _merkleProof Proof for whitelist verification
     */
    function mint(
        bytes32[] calldata _merkleProof
    ) external payable nonReentrant {
        if (!activeMint) revert MintNotActive();
        if (hasMinted[msg.sender]) revert AlreadyClaimed();
        if (totalSupply + 1 > MAX_SUPPLY) revert MaxSupplyReached();

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, leaf))
            revert InvalidProof();

        if (msg.value < mintPrice) revert InsufficientPayment();

        hasMinted[msg.sender] = true;
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        emit NFTMinted(msg.sender, totalSupply);
    }

    /**
     * @dev Owner mint function
     * @param to Address to receive the token
     */
    function mintTo(address to) external onlyOwner nonReentrant {
        if (hasMinted[to]) revert AlreadyClaimed();
        if (totalSupply + 1 > MAX_SUPPLY) revert MaxSupplyReached();

        hasMinted[to] = true;
        totalSupply++;
        _safeMint(to, totalSupply);
        emit NFTMinted(to, totalSupply);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert TransferFailed();
        emit PaymentWithdrawn(to, amount);
    }

    function updateMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRoot = _newMerkleRoot;
        emit MerkleRootUpdated(_newMerkleRoot);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
        emit BaseURIUpdated(_newBaseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        Strings.toString(tokenId),
                        ".json"
                    )
                )
                : "";
    }

    function getCurrentMinted() public view returns (uint256) {
        return totalSupply;
    }
}
