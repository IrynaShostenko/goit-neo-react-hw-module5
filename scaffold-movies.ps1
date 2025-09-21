# --- helper -------------------------------------------------
function New-TextFile($Path, [string]$Content = "") {
    New-Item -ItemType File -Path $Path -Force | Out-Null
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

# --- folders ------------------------------------------------
$dirs = @(
    "src/components/MovieCast",
    "src/components/MovieList",
    "src/components/MovieReviews",
    "src/components/Navigation",
    "src/pages/HomePage",
    "src/pages/MoviesPage",
    "src/pages/MovieDetailsPage",
    "src/pages/NotFoundPage",
    "src/services",
    "src/utils"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }

# --- templates ----------------------------------------------
$compTpl = @"
import css from './__NAME__.module.css';

export default function __NAME__() {
  return <div className={css.box}>__NAME__</div>;
}
"@

$cssTpl = @"
.box { padding: 16px; }
"@

# Components
New-TextFile "src/components/MovieCast/MovieCast.jsx" ($compTpl -replace "__NAME__", "MovieCast")
New-TextFile "src/components/MovieCast/MovieCast.module.css" $cssTpl

New-TextFile "src/components/MovieList/MovieList.jsx" @"
import { Link, useLocation } from 'react-router-dom';
import css from './MovieList.module.css';

export default function MovieList({ movies = [] }) {
  const location = useLocation();
  if (!movies.length) return null;
  return (
    <ul className={css.list}>
      {movies.map(({ id, title, name }) => (
        <li key={id}>
          <Link to={`/movies/${id}`} state={{ from: location }}>
            {title || name}
          </Link>
        </li>
      ))}
    </ul>
  );
}
"@
New-TextFile "src/components/MovieList/MovieList.module.css" @"
.list { display: grid; gap: 8px; padding: 16px; }
"@

New-TextFile "src/components/MovieReviews/MovieReviews.jsx" ($compTpl -replace "__NAME__", "MovieReviews")
New-TextFile "src/components/MovieReviews/MovieReviews.module.css" $cssTpl

New-TextFile "src/components/Navigation/Navigation.jsx" @"
import { NavLink } from 'react-router-dom';
import css from './Navigation.module.css';
const active = ({ isActive }) => (isActive ? css.active : '');
export default function Navigation() {
  return (
    <header className={css.header}>
      <nav className={css.nav}>
        <NavLink className={active} to="/">Home</NavLink>
        <NavLink className={active} to="/movies">Movies</NavLink>
      </nav>
    </header>
  );
}
"@
New-TextFile "src/components/Navigation/Navigation.module.css" @"
.header { border-bottom: 1px solid #eee; }
.nav { display: flex; gap: 16px; padding: 12px 16px; }
.active { color: #e91e63; }
"@

# Pages
New-TextFile "src/pages/HomePage/HomePage.jsx" @"
import { useEffect, useState } from 'react';
import { getTrending } from '../../services/tmdb';
import MovieList from '../../components/MovieList/MovieList';
import css from './HomePage.module.css';

export default function HomePage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  useEffect(() => {
    (async () => {
      try { setLoading(true); setMovies(await getTrending()); }
      catch { setError('Failed to load trending'); }
      finally { setLoading(false); }
    })();
  }, []);
  return (
    <main className={css.main}>
      <h1>Trending today</h1>
      {loading && <p>Loading…</p>}
      {error && <p>{error}</p>}
      <MovieList movies={movies} />
    </main>
  );
}
"@
New-TextFile "src/pages/HomePage/HomePage.module.css" " .main { padding:16px; } "

New-TextFile "src/pages/MoviesPage/MoviesPage.jsx" @"
import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { searchMovies } from '../../services/tmdb';
import MovieList from '../../components/MovieList/MovieList';
import css from './MoviesPage.module.css';

export default function MoviesPage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [params, setParams] = useSearchParams();
  const query = params.get('query') ?? '';

  useEffect(() => {
    if (!query) { setMovies([]); return; }
    (async () => {
      try { setLoading(true); setMovies(await searchMovies(query)); }
      catch { setError('Search failed'); }
      finally { setLoading(false); }
    })();
  }, [query]);

  const onSubmit = (e) => {
    e.preventDefault();
    const value = e.currentTarget.elements.search.value.trim();
    setParams(value ? { query: value } : {});
  };

  return (
    <main className={css.main}>
      <h1>Search movies</h1>
      <form onSubmit={onSubmit} className={css.form}>
        <input name='search' defaultValue={query} placeholder='Movie title…' />
        <button type='submit'>Search</button>
      </form>
      {loading && <p>Loading…</p>}
      {error && <p>{error}</p>}
      <MovieList movies={movies} />
    </main>
  );
}
"@
New-TextFile "src/pages/MoviesPage/MoviesPage.module.css" @"
.main { padding:16px; }
.form { display:flex; gap:8px; margin:12px 0; }
"@

New-TextFile "src/pages/MovieDetailsPage/MovieDetailsPage.jsx" @"
import { useEffect, useRef, useState } from 'react';
import { Link, NavLink, Outlet, useLocation, useParams } from 'react-router-dom';
import { getMovieDetails } from '../../services/tmdb';
import { IMG } from '../../utils/img';
import css from './MovieDetailsPage.module.css';

export default function MovieDetailsPage() {
  const { movieId } = useParams();
  const location = useLocation();
  const backRef = useRef(location.state?.from ?? '/movies');
  const [movie, setMovie] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    (async () => {
      try { setLoading(true); setMovie(await getMovieDetails(movieId)); }
      catch { setError('Cannot load movie'); }
      finally { setLoading(false); }
    })();
  }, [movieId]);

  if (loading) return <p className={css.main}>Loading…</p>;
  if (error) return <p className={css.main}>{error}</p>;
  if (!movie) return null;

  const { poster_path, title, release_date, vote_average, overview, genres } = movie;

  return (
    <main className={css.main}>
      <Link className={css.back} to={backRef.current}>← Go back</Link>
      <div className={css.hero}>
        <img src={IMG.poster(poster_path)} alt={title} />
        <div>
          <h2>{title} {!!release_date && `(${release_date.slice(0,4)})`}</h2>
          <p>User Score: {Math.round(vote_average * 10)}%</p>
          <h3>Overview</h3><p>{overview || 'No overview'}</p>
          <h3>Genres</h3><p>{genres?.map(g => g.name).join(' ') || '—'}</p>
        </div>
      </div>
      <section className={css.subnav}>
        <p>Additional information</p>
        <ul>
          <li><NavLink to='cast'>Cast</NavLink></li>
          <li><NavLink to='reviews'>Reviews</NavLink></li>
        </ul>
      </section>
      <Outlet />
    </main>
  );
}
"@
New-TextFile "src/pages/MovieDetailsPage/MovieDetailsPage.module.css" @"
.main { padding:16px; }
.back { display:inline-block; margin:8px 0; }
.hero { display:grid; grid-template-columns:200px 1fr; gap:16px; margin:16px 0; }
.subnav { border-top:1px solid #eee; border-bottom:1px solid #eee; padding:12px 0; margin:16px 0; }
"@

New-TextFile "src/pages/NotFoundPage/NotFoundPage.jsx" @"
import { Link } from 'react-router-dom';
import css from './NotFoundPage.module.css';
export default function NotFoundPage() {
  return (
    <main className={css.main}>
      <h1>404 — Page not found</h1>
      <p><Link to='/'>Go to Home</Link></p>
    </main>
  );
}
"@
New-TextFile "src/pages/NotFoundPage/NotFoundPage.module.css" " .main { padding:16px; } "

# services
New-TextFile "src/services/tmdb.js" @"
import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.themoviedb.org/3',
  headers: { Authorization: `Bearer ${import.meta.env.VITE_TMDB_TOKEN}` },
  params: { language: 'en-US' },
});

export const getTrending = async () => (await api.get('/trending/movie/day')).data.results;
export const searchMovies = async (query, page = 1) =>
  (await api.get('/search/movie', { params: { query, include_adult: false, page } })).data.results;
export const getMovieDetails = async (id) => (await api.get(`/movie/${id}`)).data;
export const getMovieCredits = async (id) => (await api.get(`/movie/${id}/credits`)).data.cast;
export const getMovieReviews = async (id) => (await api.get(`/movie/${id}/reviews`)).data.results;
"@

# utils
New-TextFile "src/utils/img.js" @"
export const IMG = {
  poster: (p) => (p ? `https://image.tmdb.org/t/p/w342${p}` : '/poster-fallback.png'),
  avatar: (p) => (p ? `https://image.tmdb.org/t/p/w185${p}` : '/avatar-fallback.png'),
};
"@

# App & main
New-TextFile "src/App.jsx" @"
import { Suspense, lazy } from 'react';
import { Routes, Route } from 'react-router-dom';
import Navigation from './components/Navigation/Navigation.jsx';

const HomePage = lazy(() => import('./pages/HomePage/HomePage.jsx'));
const MoviesPage = lazy(() => import('./pages/MoviesPage/MoviesPage.jsx'));
const MovieDetailsPage = lazy(() => import('./pages/MovieDetailsPage/MovieDetailsPage.jsx'));
const NotFoundPage = lazy(() => import('./pages/NotFoundPage/NotFoundPage.jsx'));
const MovieCast = lazy(() => import('./components/MovieCast/MovieCast.jsx'));
const MovieReviews = lazy(() => import('./components/MovieReviews/MovieReviews.jsx'));

export default function App() {
  return (
    <>
      <Navigation />
      <Suspense fallback={<p style={{ padding: 16 }}>Loading…</p>}>
        <Routes>
          <Route path='/' element={<HomePage />} />
          <Route path='/movies' element={<MoviesPage />} />
          <Route path='/movies/:movieId' element={<MovieDetailsPage />}>
            <Route path='cast' element={<MovieCast />} />
            <Route path='reviews' element={<MovieReviews />} />
          </Route>
          <Route path='*' element={<NotFoundPage />} />
        </Routes>
      </Suspense>
    </>
  );
}
"@

New-TextFile "src/main.jsx" @"
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.jsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
"@

Write-Host "✅ Scaffold created. Don't forget to add .env with VITE_TMDB_TOKEN." -ForegroundColor Green
