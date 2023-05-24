import { Button, Modal } from "antd";
import { useState } from "react";
import { deleteUser } from "../../../lib/api";
import { DataType } from "../../../utils/DataType";

const DeleteButton: React.FC<{ record: DataType }> = ({ record }) => {
  const [modalVisible, setModalVisible] = useState(false);

  const openModal = () => {
    setModalVisible(true);
  };

  const closeModal = () => {
    setModalVisible(false);
  };

  const handleDelete = async () => {
    try {
      await deleteUser(record.id);
      closeModal();
      window.location.reload();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <>
      <Button onClick={openModal} type="default">
        Delete
      </Button>
      <Modal
        title="Confirm Delete"
        open={modalVisible}
        onCancel={closeModal}
        footer={[
          <Button key="cancel" onClick={closeModal}>
            Cancel
          </Button>,
          <Button key="action" type="primary" onClick={handleDelete}>
            Delete
          </Button>,
        ]}
      >
        <p>Are you sure you want to delete this user?</p>
      </Modal>
    </>
  );
};

export default DeleteButton;