import React from "react";

import { Statistic, Row, Col } from "antd";


type CardStatistic = {
  statisticData: {
    title: string;
    value: number;
  }[];
};

const CardStatistic: React.FC<CardStatistic> = ({ statisticData }) => {
  return (
    <Row gutter={16}>
      {statisticData.map((statistic) => (
        <Col span={4}>
          <Statistic
            key={statistic.title}
            title={statistic.title}
            value={statistic.value}
            style={{
              paddingLeft: 10,
              border: "1px solid ",
              borderRadius: "6px",
              boxShadow: "5px 10px #888888",
              marginBottom: 50,
            }}
          />
        </Col>
      ))}
    </Row>
  );
};

export default CardStatistic;
