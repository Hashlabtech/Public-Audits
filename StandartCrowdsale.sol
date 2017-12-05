pragma solidity ^0.4.15;


contract StandartCrowdsale is Ownable, ReentrancyGuard, Stateful {

  using SafeMath for uint;

  mapping (address => uint) preICOinvestors;
  mapping (address => uint) ICOinvestors;

  BSEToken public token ;
  uint256 public start;
  uint256 public period;
  uint256 public constant rate;
  uint256 public constant softcap;
  uint256 public constant hardcap;
  uint256 day = 86400; // sec in day

  address multisig;

  modifier saleIsOn() {
    require((state == State.PreIco || state == State.ICO) &&(now < startICO + period || now < startPreICO + period));
    _;
  }

  modifier isUnderHardCap() {
    require(token.totalSupply() < getHardcap());
    _;
  }

  function getHardcap() internal returns(uint256) {
    if (state == State.PreIco) {
      return preICOTokenHardCap;
    }
    else {
      if (state == State.ICO) {
        return ICOTokenHardCap;
      }
    }
  }


  function Crowdsale(address _multisig) {
    multisig = _multisig;
    token = new BSEToken();

  }
  function startCompanySell() onlyOwner {
    require(state== State.CrowdsaleFinished);
    setState(State.companySold);
  }

  // for mint tokens to USD investor
  function usdSale(address _to, uint _valueUSD) onlyOwner  {
    uint256 valueCent = _valueUSD * 100;
    uint256 tokensAmount = rateCent.mul(valueCent);
    collectedCent += valueCent;
    token.mint(_to, tokensAmount);
  }

  function pauseSale() onlyOwner {
    setState(State.salePaused);
  }

  function startPreIco(uint256 _period) onlyOwner {
    require(state == State.Init || state == State.PreIcoPaused);
    startPreICO = now;
    period = _period * day;
    setState(State.PreIco);
  }

  function finishPreIco() onlyOwner {
    setState(State.preIcoFinished);
    bool isSent = multisig.call.gas(3000000).value(this.balance)();
    require(isSent);
  }

  function startIco(uint256 _period) onlyOwner {
    startICO = now;
    period = _period * day;
    setState(State.ICO);
  }

  function finishICO() onlyOwner {
    setState(State.CrowdsaleFinished);
    bool isSent = multisig.call.gas(3000000).value(this.balance)();
    //TODO add finishMinting
    require(isSent);

    //token.finishMinting();
  }
  function finishMinting() onlyOwner {

    token.finishMinting();

  }

  function getDouble() nonReentrant {
    require (state == State.ICO || state == State.companySold);
    uint256 extraTokensAmount;
    if (state == State.ICO) {
      extraTokensAmount = preICOinvestors[msg.sender];
      preICOinvestors[msg.sender] = 0;
      token.mint(msg.sender, extraTokensAmount);
      ICOinvestors[msg.sender] = extraTokensAmount;
    }
    else {
      if (state == State.companySold) {
        extraTokensAmount = preICOinvestors[msg.sender] + ICOinvestors[msg.sender];
        preICOinvestors[msg.sender] = 0;
        ICOinvestors[msg.sender] = 0;
        token.mint(msg.sender, extraTokensAmount);
      }
    }
  }


  function mintTokens() payable saleIsOn isUnderHardCap nonReentrant {
    uint256 valueWEI = msg.value;
    uint256 valueCent = valueWEI.div(priceUSD);
    uint256 tokens = rateCent.mul(valueCent);
    uint256 hardcap = getHardcap();
    if (token.totalSupply() + tokens > hardcap) {
      tokens = hardcap.sub(token.totalSupply());
      valueCent = tokens.div(rateCent);
      valueWEI = valueCent.mul(priceUSD);
      uint256 change = msg.value - valueWEI;
      bool isSent = msg.sender.call.gas(3000000).value(change)();
      require(isSent);
    }
    token.mint(msg.sender, tokens);
    collectedCent += valueCent;
    if (state == State.PreIco) {
      preICOinvestors[msg.sender] += tokens;
    }
    else {
      ICOinvestors[msg.sender] += tokens;
    }
  }

  function () payable {
    mintTokens();
  }
}
