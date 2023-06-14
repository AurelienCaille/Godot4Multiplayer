# Server side code

This nakama server use typescript
Off course, docker should be installed...


WIP:
<ul>
	<li>Create public match</li>
	<li>Create match with password</li>
</ul>

## How to use
<ol>
	<li>Build the image</li>
	<li>Launch server via docker</li>
</ol>

### 1° Build our custom nakama image

To build docker image with Nakama typescript
````
docker build --no-cache -t my-nakama:latest .
````
<strong>--no-cache</strong> Force to recreate the image from 0
<strong>-t my-nakama:latest</strong> Set image name as <em>my-nakama:latest</em>

### 2° Run our nakama server

To run nakama server
````
docker-compose up --force-recreate
````
<strong>--force-recreate</strong> Don't use it if you want to keep data

## Source files

Typescript files are in <strong>src</strong> folder

<ul>
	<li>main.ts: Register scripts functions</li>
	<li>healthcheck.ts: Is the server ok ?</li>
	<li>lobby.ts: Match functions</li>
</ul>