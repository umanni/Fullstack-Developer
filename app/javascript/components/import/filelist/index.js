import React from 'react';

import { Container, FileInfo } from './styles';

export default ({ files }) => {
  return (
    <Container>
      {files.map(uploadedFile => (
        <li key={uploadedFile.name}>
          <FileInfo>
            <div>
              <strong>{uploadedFile.name}</strong>
            </div>
          </FileInfo>
        </li>
      ))}
    </Container>
  );
};
