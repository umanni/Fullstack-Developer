import React from "react";
import { useHistory } from "react-router-dom";

import { Upload, message, Button, Form } from "antd";
import {UploadOutlined,DeleteOutlined} from "@ant-design/icons";

import Api from "../../services/api";

type UploadInterface = {
  name?: string;
  onLoadUsers(): void;
};

const UploadProgress: React.FC<UploadInterface> = ({
  onLoadUsers,
  name = " Click to Upload",
}) => {
  const history = useHistory();

  const normFile = (e: any) => {
    if (Array.isArray(e)) {
      return e;
    }
    return e && e.fileList;
  };

  const onFinish = (file: any) => {
    
    const data = new FormData();
    data.append("attachment", file.attachment[0].originFileObj);
    data.append("name", "import users");

    const config = {
      headers: {
        "content-type":
          "multipart/form-data; boundary=ebf9f03029db4c2799ae16b5428b06bd",
      },
    };

    Api.post("user-imports", data, config)
      .then((res: any) => {
        message.success(res.data.success);
        onLoadUsers();
        history.push("/dashboard");
      })
      .catch((err: Error) => {
        message.error(`Error to upload file!`);
      });
  };

  const prop = {
    key: "upload-1",
    name: "attachment",
    accept: ".xls, .xlsx",
    multiple: true,
    action: "https://www.mocky.io/v2/5cc8019d300000980a055e76",
    showUploadList: {
      showDownloadIcon: false,
      downloadIcon: "download ",
      showRemoveIcon: true,
      removeIcon: ( <DeleteOutlined /> ),
    },
  };

  return (
    <Form name="validate_other" layout="inline" onFinish={onFinish}>
      <Form.Item
        name="attachment"
        valuePropName="fileList"
        getValueFromEvent={normFile}
        style={{ width: 200 }}
      >
        <Upload {...prop}>
          <Button>
            <UploadOutlined /> {name}
          </Button>
        </Upload>
      </Form.Item>
      
      <Form.Item>
        <Button type="primary" htmlType="submit">
          Upload Cloud
        </Button>
      </Form.Item>
    </Form>
  );
};

export default UploadProgress;
