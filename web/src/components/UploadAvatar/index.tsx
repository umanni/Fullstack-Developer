import React, { useState } from "react";
import { Upload, message } from "antd";
import { LoadingOutlined, PlusOutlined } from "@ant-design/icons";

import "./styles.css";

function getBase64(img: any, callback: any) {
  const reader = new FileReader();
  reader.addEventListener("load", () => callback(reader.result));
  reader.readAsDataURL(img);
}

function beforeUpload(file: any) {
  const isJpgOrPng = file.type === "image/jpeg" || file.type === "image/png";
  if (!isJpgOrPng) {
    message.error("You can only upload JPG/PNG file!");
  }
  const isLt2M = file.size / 1024 / 1024 < 2;
  if (!isLt2M) {
    message.error("Image must smaller than 2MB!");
  }
  return isJpgOrPng && isLt2M;
}

interface UploadInterface {
  loading?: any;
  imageUrl?: any;
}

type UploadAvatar = {
  name?: string;
};

const Avatar: React.FC<UploadAvatar> = ({ name = "avatar" }) => {
  const [loadingUpload, setLoadingUpload] = useState<UploadInterface>({
    loading: false,
  });

  const handleChange = (info: any) => {
    if (info.file.status === "uploading") {
      setLoadingUpload({ loading: true });
      return;
    }
    if (info.file.status === "done") {
      getBase64(info.file.originFileObj, (imageUrl: any) =>
        setLoadingUpload({
          imageUrl,
          loading: false,
        })
      );
    }
  };

  const uploadButton = (
    <div>
      {loadingUpload.loading ? <LoadingOutlined /> : <PlusOutlined />}
      <div className="ant-upload-text">Upload</div>
    </div>
  );
  const { imageUrl } = loadingUpload;

  return (
    <Upload
      name={name}
      listType="picture-card"
      className="avatar-uploader"
      showUploadList={false}
      action="https://www.mocky.io/v2/5cc8019d300000980a055e76"
      beforeUpload={beforeUpload}
      onChange={handleChange}
    >
      {imageUrl ? (
        <img src={imageUrl} alt="avatar" style={{ width: "100%" }} />
      ) : (
        uploadButton
      )}
    </Upload>
  );
};

export default Avatar;
