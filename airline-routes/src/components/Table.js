import React, { Component } from 'react';

class Table extends Component {
  state = {
    rowNum: 0
  }

  isFirstPage = () => {
    return this.state.rowNum === 0;
  }

  isLastPage = () => {
    return this.props.rows.length - this.state.rowNum <= this.props.perPage;
  }

  handleNextPage = () => {
    this.setState((state, props) => {
      return {
        rowNum: state.rowNum + props.perPage,
      }
    })
  }

  handlePrevPage = () => {
    this.setState((state, props) => {
      const prevRow = (state.rowNum - props.perPage >= 0) ? state.rowNum - props.perPage : 0;
      return {
        rowNum: prevRow,
      }
    })
  }

  render() {
    let [ firstRow, lastRow ] = [this.state.rowNum, this.state.rowNum + this.props.perPage];
    lastRow = (lastRow > this.props.rows.length) ?
              this.props.rows.length : lastRow;
    const displayedRows = this.props.rows.slice(firstRow, lastRow);

    return (
      <div>
        <table className={this.props.className}>
          <thead>
            <tr>
              {this.props.columns.map(column => (
                <th key={column.name}>{column.name}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {displayedRows.map(route => {
              return (
                <tr key={String(route.airline) + route.src + route.dest}>
                  <td>{this.props.format('airline', route.airline)}</td>
                  <td>{this.props.format('airport', route.src)}</td>
                  <td>{this.props.format('airport', route.dest)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
        <p>Showing {this.props.rows.length > 0 ? firstRow + 1 : 0}-{lastRow} of {this.props.rows.length} routes.</p>
        <button
          onClick={this.handlePrevPage}
          disabled={this.isFirstPage()}
        >
          Previous Page
        </button>
        <button
          onClick={this.handleNextPage}
          disabled={this.isLastPage()}
        >
          Next Page
        </button>
      </div>
    )
  }
}

export default Table;