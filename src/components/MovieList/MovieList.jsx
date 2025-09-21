import { Link, useLocation } from "react-router-dom";
import PropTypes from "prop-types";
import css from "./MovieList.module.css";

function MovieList({ movies }) {
  const location = useLocation();
  if (!movies?.length) return null;

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

MovieList.propTypes = {
  movies: PropTypes.array.isRequired,
};

export default MovieList;