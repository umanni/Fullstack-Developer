import React, { useState } from 'react';
import { useHistory } from 'react-router-dom';

import { Container, ImportFileContainer, Footer } from './styles';

import Api from '@/services/api';

import FileList from '@/components/import/filelist';
import Dropzone from '@/components/import/dropzone';
import TopBar from '@/components/TopBar';
import SideBar from '@/components/sidebar/SideBar';

export default () => {
  const [uploadedFiles, setUploadedFiles] = useState([]);
  const history = useHistory();

  async function handleUpload(){
    const data = new FormData();

    if (!uploadedFiles.length) return;

    try {
      data.append('file', uploadedFiles[0].file);

      Api.post('/api/import', data).then(() => {
        history.push('/dashboard');
      }).catch(() => {
      });
    } catch (err) {

    }
  }

  function submitFile(files) {
    const uploadFiles = files.map(file => ({
      file,
      name: file.name,
    }));

    setUploadedFiles(uploadFiles);
  }

  return (
    <>
      <Container>
        <TopBar />
        <SideBar />

        <ImportFileContainer>
          <Dropzone onUpload={submitFile} />
          {!!uploadedFiles.length && <FileList files={uploadedFiles} />}

          <Footer>
            <p>
              Permitido apenas arquivos CSV
            </p>
            <button onClick={handleUpload} type="button">
              Enviar
            </button>
          </Footer>
        </ImportFileContainer>
      </Container>
    </>
  );
};
