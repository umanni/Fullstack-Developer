import React from "react";

import { Button } from "antd";

interface Props {
  name: string;
  icon: object;
  danger?: boolean;
  onClickAction(): void;
}

const ButtonCustom: React.FC<Props> = ({
  onClickAction,
  name,
  icon,
  danger,
}) => {
  return (
    <Button type="primary" onClick={onClickAction} icon={icon} danger={danger}>
      {name}
    </Button>
  );
};

export default ButtonCustom;
