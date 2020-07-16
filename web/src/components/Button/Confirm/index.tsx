import React from "react";

import { Modal, Button } from "antd";
const { confirm } = Modal;

interface Props {
  name: string;
  title: string;
  content: string;
  icon: object;
  danger?: boolean;
  onConfirm(): void;
}

const ButtonConfim: React.FC<Props> = ({
  onConfirm,
  title,
  name,
  content,
  icon,
  danger,
}) => {
  const showConfirm = () => {
    confirm({
      title,
      icon,
      content,
      onOk() {
        onConfirm();
      },
    });
  };

  return (
    <Button type="primary" onClick={showConfirm} icon={icon} danger={danger}>
      {name}
    </Button>
  );
};

export default ButtonConfim;
