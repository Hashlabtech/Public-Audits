pragma solidity ^0.4.15;


contract Stateful {
  enum State {
  Init,
  PreIco,
  preIcoFinished,
  ICO,
  CrowdsaleFinished
  }
  State public state = State.Init;

  event StateChanged(State oldState, State newState);

  function setState(State newState) internal {
    State oldState = state;
    state = newState;
    StateChanged(oldState, newState);
  }
}


contract main {

  modifier onlyAtVoting() {

  }

  function approveRequest() onlyAtVoting {

  }

  function declineRequest() onlyAtVoting {

  }

  function requestMoney(address _to) {

  }

  function () payable {}


}
