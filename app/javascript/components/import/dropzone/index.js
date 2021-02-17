import React, { ReactNode } from 'react';

import Dropzone from 'react-dropzone';
import { DropContainer, UploadMessage } from './styles';

export default ({ onUpload }) => {
  function renderDragMessage(
    isDragActive,
    isDragRejest,
  ) {
    if (!isDragActive) {
      return (
        <UploadMessage>Select or drop the file here.</UploadMessage>
      );
    }

    if (isDragRejest) {
      return <UploadMessage type="error">File not supported</UploadMessage>;
    }

    return <UploadMessage type="success">Drag the file here</UploadMessage>;
  }

  return (
    <>
      <Dropzone
        accept=".csv, application/vnd.ms-excel, text/csv"
        onDropAccepted={files => onUpload(files)}
      >
        {({ getRootProps, getInputProps, isDragActive, isDragReject }) => (
          <DropContainer
            {...getRootProps()}
            isDragActive={isDragActive}
            isDragReject={isDragReject}
          >
            <input {...getInputProps()} />
            {renderDragMessage(isDragActive, isDragReject)}
          </DropContainer>
        )}
      </Dropzone>
    </>
  );
};
