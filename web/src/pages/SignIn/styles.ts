import styled from "styled-components";

export const Container = styled.div`
  background: #fff;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
`;

export const Content = styled.div`
  width: 350px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  border: 2px;
  border-style: solid;
  border-radius: 6px;
  border-color: #cacaca;

  .avatar {
    margin-bottom: 20px;
  }

  .title {
    color: #1890ff;
    margin-bottom: 20px;
  }

  .login-form {
    max-width: 350px;
  }
  .login-form-forgot {
    float: right;
  }
  .ant-col-rtl .login-form-forgot {
    float: left;
  }
  .login-form-button {
    width: 100%;
  }
`;
