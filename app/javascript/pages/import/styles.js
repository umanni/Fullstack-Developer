import styled from 'styled-components';
import {shade} from 'polished';

export const Container = styled.div`
  width: 100%;
  max-width: 1120px;
  margin: 0 auto;
  padding: 40px 256px;
`;

export const ImportFileContainer = styled.section`
  background: #fff;
  color: #999;
  margin-top: 40px;
  border-radius: 5px;
  padding: 64px;
`;

export const Footer = styled.section`
  margin-top: 36px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  p {
    display: flex;
    align-items: center;
    font-size: 12px;
    line-height: 18px;
    color: #999;
    img {
      margin-right: 5px;
    }
  }
  button {
    background: #4051B5;
    color: #fff;
    border-radius: 5px;
    padding: 15px 80px;
    border: 0;
    transition: background-color 0.2s;
    cursor: pointer;
    &:hover {
      background: ${shade(0.2, '#4050B5')};
    }
  }
`;
