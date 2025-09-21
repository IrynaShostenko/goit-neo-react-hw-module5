import axios from 'axios';

const api = axios.create({
  baseURL: 'https://api.themoviedb.org/3',
  headers: {
    Authorization: `Bearer ${import.meta.env.VITE_TMDB_TOKEN}`,
  },
  params: { language: 'en-US' },
});

export const getTrending = async () => {
  const { data } = await api.get('/trending/movie/day');
  return data.results;
};

export const searchMovies = async (query, page = 1) => {
  const { data } = await api.get('/search/movie', {
    params: { query, include_adult: false, page },
  });
  return data.results;
};

export const getMovieDetails = async id => {
  const { data } = await api.get(`/movie/${id}`);
  return data;
};

export const getMovieCredits = async id => {
  const { data } = await api.get(`/movie/${id}/credits`);
  return data.cast;
};

export const getMovieReviews = async id => {
  const { data } = await api.get(`/movie/${id}/reviews`);
  return data.results;
};
