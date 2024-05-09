import React, { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import clsx from 'clsx';
import style from './Login.module.scss';
import logo from '../../img/logoCoffee.png'

function Login() {
    const loginRef = useRef(null);
    const Username = useRef(null);
    const Password = useRef(null);
    const navigate = useNavigate();

    async function checkAuth(username, password) {
            if (username === 'admin' && password === '123456') {
                navigate('/dashboard');
            }
    };

    useEffect(() => {
      loginRef.current.onclick = () => {
          checkAuth(Username.current.value, Password.current.value);
      };

      Password.current.addEventListener('keypress', (event) => {
          if (event.key === 'Enter') {
              checkAuth(Username.current.value, Password.current.value);
          }
      });
     

  }, []);

    return (
        <div className={clsx(style.wrapper)}>
            <div className={clsx(style.subwrapper)}>
              <img src={logo} alt="Logo" className={clsx(style.logo)} />
                <div className={clsx(style.login)}>
                    <h1>Login</h1>
                    <div>
                        <label className={clsx(style.label)}>Uername</label>
                        <input ref={Username} type="text" placeholder="Username" autoFocus/>

                        <label className={clsx(style.label)}>Password</label>
                        <input ref={Password} type="password" placeholder="Password" />

                        <button ref={loginRef} className={clsx(style.btn, 'btn btn-primary btn-block btn-large')}>
                            Login
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default Login;
