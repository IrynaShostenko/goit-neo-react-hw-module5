import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getMovieReviews } from "../../services/tmdb";
import css from "./MovieReviews.module.css";

function MovieReviews() {
  const { movieId } = useParams();
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setReviews(await getMovieReviews(movieId));
      } catch {
        setError("Failed to load reviews");
      } finally {
        setLoading(false);
      }
    })();
  }, [movieId]);

  if (loading) return <p>Loading reviews…</p>;
  if (error) return <p>{error}</p>;
  if (!reviews?.length) return <p>No reviews.</p>;

  return (
    <ul className={css.list}>
      {reviews.map(({ id, author, content, url }) => (
        <li key={id} className={css.item}>
          <p><b>{author}</b></p>
          <p>{content}</p>
          {url && <a href={url} target="_blank" rel="noreferrer">Source</a>}
        </li>
      ))}
    </ul>
  );
}

export default MovieReviews;