import React, { Component } from 'react';

class Select extends Component {

  constructor(props) {
    super(props);
    this.state = {
      allOptions: this.props.filteredOptions,
    }
  }

  isDisabled = (option) => {
    return !this.props.filteredOptions.find(o => o.name === option);
  }

  render(){
    return (
      <select
        name={this.props.titleKey}
        id={this.props.valueKey}
        onChange={this.props.onSelect}
        value={this.props.value}
      >
        <option>{this.props.allTitle}</option>
        {this.state.allOptions.map((option, idx) => {
          return (
            <option
              key={option.name + String(idx)}
              disabled={this.isDisabled(option.name)}
            >
              {option.name}
            </option>
          )
        })}
      </select>
    )
  }
}

export default Select;