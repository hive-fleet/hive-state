defmodule Hive.H3 do
  @moduledoc """
  Interfaces with Erlang H3 and provides abstraction
  layer to work with vehicles or `%GeoPosition{}`.

  ## Usage

    iex> Hive.H3.num_hexagons(resolution)
  """
  use Hive.Base

  @type vehicle_id() :: binary()
  @type h3_index() :: non_neg_integer()
  @type resolution() :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15

  @doc """
  Indexes the location at the specified resolution
  """
  @spec index(GeoPosition.t(), resolution()) :: h3_index()
  def index(%GeoPosition{latitude: lat, longitude: lon}, resolution) do
    :h3.from_geo({lat, lon}, resolution)
  end

  @doc """
  Indexes the location for given `vehicle_id` at the specified resolution
  """
  @spec index(vehicle_id(), resolution()) :: h3_index()
  def index(vehicle_id, resolution) do
    position = VehicleWorker.get_position(%Vehicle{id: vehicle_id})
    :h3.from_geo({position.latitude, position.longitude}, resolution)
  end

  @doc """
  Convert string representation of H3 index to
  numeric index value.

  Example:

    iex> Hive.H3.from_string("8928308280fffff")
  """
  @spec from_string(binary()) :: h3_index()
  def from_string(index) do
    index
    |> String.to_charlist()
    |> :h3.from_string()
  end

  @doc """
  Convert string representation of H3 index to
  numeric index value.

  Example:

    iex> Hive.H3.to_string(617_700_169_958_293_503)
  """
  @spec to_hex_string(non_neg_integer()) :: binary()
  def to_hex_string(index) do
    index
    |> :h3.to_string()
    |> List.to_string()
  end

  @doc """
  Returns the `%GeoPosition{}` center of the cell
  from string representation
  """
  @spec index_to_geo(binary()) :: GeoPosition.t()
  def index_to_geo(index) when is_binary(index) do
    index
    |> from_string()
    |> index_to_geo()
  end

  @doc """
  Returns the `%GeoPosition{}` center of the cell
  from numeric index
  """
  @spec index_to_geo(h3_index()) :: GeoPosition.t()
  def index_to_geo(index) do
    {lat, lon} = :h3.to_geo(index)

    %GeoPosition{
      latitude: lat,
      longitude: lon
    }
  end

  @doc """
  Returns index from `%GeoPosition{}`
  """
  @spec index_from_geo(GeoPosition.t(), resolution()) :: h3_index()
  def index_from_geo(position, resolution) do
    :h3.from_geo(
      {position.latitude, position.longitude},
      resolution
    )
  end

  @doc """
  Returns bounds for index
  """
  @spec to_geo_boundary(binary()) :: list(GeoPosition.t())
  def to_geo_boundary(index) when is_binary(index) do
    index
    |> from_string()
    |> to_geo_boundary()
  end

  @doc """
  Returns bounds for index
  """
  @spec to_geo_boundary(h3_index()) :: list(GeoPosition.t())
  def to_geo_boundary(index) do
    index
    |> :h3.to_geo_boundary()
    |> Enum.map(fn {lat, lon} ->
      %GeoPosition{latitude: lat, longitude: lon}
    end)
  end

  @doc """
  Returns the resolution of the index.
  """
  @spec get_resolution(h3_index()) :: resolution()
  def get_resolution(index) do
    :h3.get_resolution(index)
  end

  @doc """
  Check if given index represents a pentagonal cell
  """
  @spec pentagon?(h3_index()) :: boolean()
  def pentagon?(index) do
    :h3.is_pentagon(index)
  end

  @doc """
  Get all hexagons in a k-ring around
  a given center and a distance.
  """
  @spec k_ring(binary(), non_neg_integer()) :: list(h3_index())
  def k_ring(index, distance) when is_binary(index) do
    index
    |> from_string()
    |> k_ring(distance)
  end

  @doc """
  Get all hexagons in a k-ring around
  a given center and a distance.
  """
  @spec k_ring(h3_index(), non_neg_integer()) :: list(h3_index())
  def k_ring(index, distance) do
    :h3.k_ring(index, distance)
    |> Enum.map(&to_hex_string/1)
  end
end
