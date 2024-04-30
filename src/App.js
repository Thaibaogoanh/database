import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { publicRoutes } from './routes';
import DefaultLayout from './components/Layout';
import { Fragment } from 'react';

function App() {
    return (
        <BrowserRouter>
            <div className="app">
                <Routes>
                    {publicRoutes.map((route, index) => {
                        const Pages = route.component;
                        const Layout = route.layout === null ? Fragment : DefaultLayout;

                        return (
                            <Route
                                key={index}
                                path={route.path}
                                element={
                                    <Layout>
                                        <Pages />
                                    </Layout>
                                }
                            />
                        );
                    })}
                </Routes>
            </div>
        </BrowserRouter>
    );
}

export default App;
