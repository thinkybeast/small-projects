import React, { Component } from 'react';

class Map extends Component {


  render() {
    return (
      <svg className="map" viewBox="-180 -90 360 180">
        <g transform="scale(1 -1)">
          <image xlinkHref="equirectangular_world.jpg" href="equirectangular_world.jpg" x="-180" y="-90" height="100%" width="100%" transform="scale(1 -1)"/>

          {
            this.props.routes.map((route, idx) => {
              const src = this.props.getAirport(route.src);
              const dest = this.props.getAirport(route.dest);
              return (
                <g key={idx}>
                  <circle className="source" cx={src.long} cy={src.lat}>
                    <title></title>
                  </circle>
                  <circle className="destination" cx={dest.long} cy={dest.lat}>
                    <title></title>
                  </circle>
                  <path d={`M${src.long} ${src.lat} L ${dest.long} ${dest.lat}`} />
                </g>
              );
           })
          }

        </g>
      </svg>
    );
  }
}


export default Map;